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
    puts "Player.count = #{Player.count}"
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

      # create draft
      # draft = user.drafts.first.build
      draft = ActiveRecord::Base::Draft.find_or_create_by_user_id( :user_id => user.id ) # bug: does not allow for users with more than one draft. Possible solution: match by user_id and name
      # create league
      league_attributes[:draft_id] = draft.id
      league = ActiveRecord::Base::League.find_or_create_by_draft_id( :draft_id => draft.id )
      league.update_attributes(league_attributes)
      
      # build_and_upsert_teams_and_owners(user_id)
      teams_owners_attributes = []
      teams_slots_attributes = []
      
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
        teams_slots_attributes << team_attr.delete(:slots_attributes) if team_attr[:slots_attributes] # this should no longer be in the team_attributes hash
              
        team_attr
      end
            
      UpdatesAndInserts.upsert( Team, teams_attributes, :league_team_id, :league_id )
      
       # assigns team_id to owner
       teams_owners_attributes.map! do |owners_attr|
         owners_attr[0][:team_id] = Team.where( :owner_hex_id => owners_attr[0][:cbs_hex_id])[0].id
         owners_attr[0][:created_at] = Time.now
         owners_attr[0][:updated_at] = Time.now
         owners_attr[0]
       end
            
       UpdatesAndInserts.upsert( Owner, teams_owners_attributes, :cbs_hex_id )

      # 
      # all_owners = []
      # all_slots = []
      # #iterate over teams to create owner and slot objects
      # teams.length.times do |i|
      #   owners = []
      #   slots = []
      #   team = teams[i]
      #   owners_attributes = teams_owners_attributes[i]
      #   slots_attributes = teams_slots_attributes[i]
      # 
      #   #build owners for team
      #   owners_attributes.each do |owner_attr|
      #     owner_attr[:team_id] = team.id
      #     owner = Owner.new(owner_attr)
      #     owners << owner
      #   end
      # 
      #   # build_slots for team
      #   slots_attributes.each do |slot_attr|
      #     slot_attr[:team_id] = team.id
      #     slots << Slot.new(slot_attr)
      #   end
      # 
      # end
      # 
      #   all_owners << owners
      #   all_slots << slots
      # 
      #   # import owners and slots
      #   Owner.import(all_owners.flatten!)
      #   Slot.import(all_slots.flatten!)
      # 
      # #def build_and_import_rounds_and_picks
      # rounds = []
      # picks = []
      # rounds_attributes.each do |round_attr|
      #   pick_attributes = round_attr.delete(:picks_attributes)
      #   round_attr[:draft_id] = draft.id
      #   round = Rounds.new(round_attr)
      #   rounds << round
      #   pick_attributes.each do |pick_attr|
      #     pick_attr[:round_id] = round.id
      #     pick_attr[:draft_id] = draft.id
      #     pick = Pick.new(pick_attr)
      #     picks << pick
      #   end
      # end
      # Round.import(rounds)
      # Pick.import(picks)

    end
  end

end