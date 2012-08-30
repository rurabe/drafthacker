module UpdatesAndInserts

  def self.upsert( activerecord_model, array_of_hashes, *index_columns )
      if array_of_hashes.class == Array
        Upsert.batch( activerecord_model.connection, activerecord_model.table_name ) do |upsert|
          array_of_hashes.each do |hash|
            index_hash = {}
            index_columns.each { |index_column| index_hash[index_column] = hash.delete(index_column) }      
            upsert.row( index_hash, hash ) # This syntax is fine.            
          end          
        end
      else
        # :error => "you must provide an array of attribute hashes"
      end
    end

  def self.upsert_players
    extend ApiCall
    player_count = Player.count
    
    players = json_response( { :api_call => 'players/list', :params => { :SPORT => "football" } } )[:body][:players]
    players.map! do |player|
      player[:created_at] = Time.now # upsert does not seem to handle created_at and updated_at
      player[:updated_at] = Time.now # it errors if either are missing, whether or not the row exists already
      player[:cbs_id] = player.delete(:id)
      
      if player[:icons]
      player[:icons_injury] = player[:icons][:injury] if player[:icons][:injury]
      player[:icons_headline] = player[:icons][:headline] if player[:icons][:headline]
      player.delete(:icons)
      end
      
      player
    end
    upsert(Player, players, :cbs_id)
    
    new_player_count = Player.count
    # checks to see if the player count has changed
    if player_count == new_player_count
      puts "Player count is still #{new_player_count}"
    else
      puts "Player count is now #{new_player_count}. Player count has changed by #{player_count - new_player_count}"
    end
    
    return true
  end
  
  
  class Import
    # {"access_token"=>"U2FsdGVkX1_HCIPbA_64gmMdBdtgQtHP8lQhYvBkqhDcL0OBTXcEXIxw58p47HWF3wnNXAvskj4FCEjcFJf5A5J0SfCXbaKtkKA0NhCCBQ7c94E9T1VaToWNHhowCWo2", "user_id"=>"b2c7c77e1b22e0f4", "SPORT"=>"football", "league_id"=>"3531-h2h", "controller"=>"drafts", "action"=>"show"}
    # Cbs::League.build_hash_league_details("U2FsdGVkX1_HCIPbA_64gmMdBdtgQtHP8lQhYvBkqhDcL0OBTXcEXIxw58p47HWF3wnNXAvskj4FCEjcFJf5A5J0SfCXbaKtkKA0NhCCBQ7c94E9T1VaToWNHhowCWo2").merge(Cbs::League.build_hash_draft_config("U2FsdGVkX1_HCIPbA_64gmMdBdtgQtHP8lQhYvBkqhDcL0OBTXcEXIxw58p47HWF3wnNXAvskj4FCEjcFJf5A5J0SfCXbaKtkKA0NhCCBQ7c94E9T1VaToWNHhowCWo2"))
    # Cbs::League.build_hash_fantasy_teams("U2FsdGVkX1_HCIPbA_64gmMdBdtgQtHP8lQhYvBkqhDcL0OBTXcEXIxw58p47HWF3wnNXAvskj4FCEjcFJf5A5J0SfCXbaKtkKA0NhCCBQ7c94E9T1VaToWNHhowCWo2")
    # Cbs::League.build_slots_array("U2FsdGVkX1_HCIPbA_64gmMdBdtgQtHP8lQhYvBkqhDcL0OBTXcEXIxw58p47HWF3wnNXAvskj4FCEjcFJf5A5J0SfCXbaKtkKA0NhCCBQ7c94E9T1VaToWNHhowCWo2")
    # Cbs::League.build_hash_draft_order("U2FsdGVkX1_HCIPbA_64gmMdBdtgQtHP8lQhYvBkqhDcL0OBTXcEXIxw58p47HWF3wnNXAvskj4FCEjcFJf5A5J0SfCXbaKtkKA0NhCCBQ7c94E9T1VaToWNHhowCWo2")
    def self.batch_create_all(options = {}) # e.g. {"access_token"=>"U2FsdGVkX1_HCIPbA_64gmMdBdtgQtHP8lQhYvBkqhDcL0OBTXcEXIxw58p47HWF3wnNXAvskj4FCEjcFJf5A5J0SfCXbaKtkKA0NhCCBQ7c94E9T1VaToWNHhowCWo2", "user_id"=>"b2c7c77e1b22e0f4", "SPORT"=>"football", "league_id"=>"3531-h2h", "controller"=>"drafts", "action"=>"show"}
      cbs_id = options.fetch("user_id")
      access_token = options.fetch("access_token")

      # API responses assigned to local variables
      league_attributes = Cbs::League.build_hash_league_details(access_token).merge(Cbs::League.build_hash_draft_config(access_token))
      teams_attributes = Cbs::League.build_hash_fantasy_teams(access_token)
      slots_attributes = Cbs::League.build_slots_array(access_token)
      rounds_attributes = Cbs::League.build_hash_draft_order(access_token)

      # find or create user
      user = User.find_or_create_by_cbs_id( :cbs_id => cbs_id )

      # find or create draft # bug: does not allow for users with more than one draft. Possible solution: match by user_id and name
      draft = ActiveRecord::Base::Draft.find_or_create_by_user_id( :user_id => user.id ) 
      draft_id = draft.id
      
      # find or create and update league
      league_attributes[:draft_id] = draft_id
      league = ActiveRecord::Base::League.find_or_create_by_draft_id( :draft_id => draft_id )
      league_id = league.id
      league.update_attributes(league_attributes)
      
      # build_and_upsert_teams_and_owners
      teams_owners_attributes = []
      
      # sanitizes teams_attributes to be compatible with the upsert method
      teams_attributes.map! do |team_attr|
        team_attr[:league_id] = league.id
        team_attr[:created_at] = Time.now
        team_attr[:updated_at] = Time.now
        team_attr[:user_id] = user.id # bug: this will not work when we optimize for multiple users in the same league. we should delete the user_id column from the db

        if team_attr[:owners_attributes][0]
          team_attr[:owner_hex_id] = team_attr[:owners_attributes][0][:cbs_hex_id] if team_attr[:owners_attributes][0][:cbs_hex_id]
        end
        
        # removes owners_attributes and slots_attributes
        teams_owners_attributes << team_attr.delete(:owners_attributes) if team_attr[:owners_attributes]
        team_attr.delete(:slots_attributes) if team_attr[:slots_attributes] # this should no longer be in the team_attributes hash
              
        team_attr
      end
            
      UpdatesAndInserts.upsert( Team, teams_attributes, :league_team_id, :league_id )
      
       # santizes owners attributes to be compatible with the upsert method
       teams_owners_attributes.map! do |owners_attr|
         # owners_attr is an array of hashes
         owners_attr[0][:team_id] = Team.where( :owner_hex_id => owners_attr[0][:cbs_hex_id])[0].id
         owners_attr[0][:created_at] = Time.now
         owners_attr[0][:updated_at] = Time.now
         owners_attr[0]
       end
            
       UpdatesAndInserts.upsert( Owner, teams_owners_attributes, :cbs_hex_id )
      
      #iterate over teams in the league to create upsert slot rows
      teams = Team.where( :league_id => league_id )
      # binding.pry
      teams.each do |team|
        slots = slots_attributes

        team_id = team.id
        number = 1

        slots.map! do |slot_attr|  # slots_attributes now returns an array instead of {:slots_attributes => [] }
          slot_attr[:number] = number
          slot_attr[:team_id] = team_id # bug! team_id is nil
          slot_attr[:created_at] = Time.now
          slot_attr[:updated_at] = Time.now
          number += 1
        slot_attr
        end

        UpdatesAndInserts.upsert( Slot, slots, :team_id, :number ) # there is probably a way to aggregate this. it currently pings the db 10 times.
      end
      
      # upsert rounds and picks
      picks_attributes = []
      rounds_attributes.map! do |round_attr|
        round_attr[:picks_attributes].each do |pick_attr| 
          pick_attr[:round_number] = round_attr[:number]
          pick_attr[:draft_id] = draft_id
          pick_attr[:created_at] = Time.now
          pick_attr[:updated_at] = Time.now
          pick_attr[:team_id] = Team.where( :league_team_id => pick_attr[:league_team_id], :league_id => league_id ).first.id
        end
        picks_attributes << round_attr.delete(:picks_attributes) # comes with number and league_team_id attributes # also has player, team, and round_id columns
        
        round_attr[:draft_id] = draft_id
        round_attr[:created_at] = Time.now
        round_attr[:updated_at] = Time.now
        
        round_attr
      end
      UpdatesAndInserts.upsert( Round, rounds_attributes, :draft_id, :number )
      
      picks_attributes.map! do |picks| # picks_attributes is an array containing arrays of picks (for each round) that contain pick attribute hashes
        round_id = Round.where( :draft_id => picks[0][:draft_id], :number => picks[0][:round_number] ).first.id
        picks.map! do |pick_attr|
          pick_attr[:round_id] = round_id
          pick_attr
        end
        picks
      end
      UpdatesAndInserts.upsert( Pick, picks_attributes.flatten!, :draft_id, :round_id, :number ) # picks_attributes needs to be an array of hashes not arrays, thus the flattening
    end
  end

end