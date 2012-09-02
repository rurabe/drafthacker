module UpdatesAndInserts

  def self.upsert( activerecord_model, array_of_hashes, *index_columns )
      if array_of_hashes.class == Array
        Upsert.batch( activerecord_model.connection, activerecord_model.table_name ) do |upsert|
          array_of_hashes.each do |hash|
            index_hash = {}            
            index_columns.each { |index_column| index_hash[index_column] = hash.delete(index_column) }      
            upsert.row( index_hash, hash ) # This syntax is fine.  
            # binding.pry
                      
          end          
        end
        # binding.pry
        
      else
        # :error => "you must provide an array of attribute hashes"
      end
    end

  class Players
    extend ApiCall
    
    def self.upsert_all
      player_count = Player.count
      
      upsert_base
      upsert_adp
      upsert_auction_values
      
      new_player_count = Player.count
      
      # checks to see if the player count has changed
      if player_count == new_player_count
        puts "Player count is still #{new_player_count}"
      else
        puts "Player count is now #{new_player_count}. Player count has changed by #{new_player_count - player_count}"
      end
    
      return true
    end


    # Upserts the db with all players or updates them if they already exist. Approximately 2827 total.
    def self.upsert_base
      #  {:bye_week=>"8", :firstname=>"Arian", :position=>"RB", :icons=>{:headline=>"Foster barrels into end zone"}, :lastname=>"Foster", :pro_status=>"A", :fullname=>"Arian Foster", :id=>"518611", :pro_team=>"HOU"}
      players = json_response( { :api_call => 'players/list', :params => { :SPORT => "football" } } )[:body][:players]
      clean_and_upsert(players)
    end

    # Upserts ADP information to Players
    def self.upsert_adp
      # {:pct=>"99.3", :bye_week=>"8", :firstname=>"Arian", :change=>0, :avg=>"1.84", :position=>"RB", :lastname=>"Foster", :high=>"1", :pro_status=>"A", :low=>"5", :fullname=>"Arian Foster", :id=>"518611", :rank=>1, :pro_team=>"HOU"}
      players = json_response( { :api_call => 'players/average-draft-position', :params => { :SPORT => "football" } } )[:body][:average_draft_position][:players]    
      clean_and_upsert(players)
    end

    # Upserts Auction Values to Players
    def self.upsert_auction_values
      # A brief discussion of these can be found at http://fantasynews.cbssports.com/fantasyfootball/rankings
      auction_values = build_auction_values
      clean_and_upsert(auction_values)
    end

    private
      def self.clean_and_upsert( players, needs_cleaning = true )
        # Take each player hash
        players.map! do |player|
          # Clean the hash for reserved words and to match our schema
          clean_player_hash(player) if needs_cleaning
        end
        UpdatesAndInserts.upsert( Player, players, :cbs_id)
      end

      def self.clean_player_hash(hash)
        # Certain keys from the CBS JSON response need to be reassigned for reserved words, conflicts, etc.
        hash[:cbs_id]     = hash.delete :id # might need to turn this into an integer
        hash[:first_name] = hash.delete :firstname  if hash[:firstname]
        hash[:last_name]  = hash.delete :lastname   if hash[:lastname]
        hash[:full_name]  = hash.delete :fullname   if hash[:fullname]
        hash[:created_at] = Time.now
        hash[:updated_at] = Time.now
        if hash[:icons]
          hash[:icons_headline] = hash[:icons][:headline]
          hash[:icons_injury] = hash[:icons][:injury]
          hash.delete :icons
        end
        hash
      end

      def self.build_auction_values
        # The various types of auction values available to us.
        sources = ['cbs','cbs_ppr','dave_richard','dave_richard_ppr','jamey_eisenberg','jamey_eisenberg_ppr','nathan_zegura']
        # An empty array for the results
        auction_values = []
        # So for each of these sources:
        sources.each do |source|
          # Get the data. It's in a weird format eg. {"187741": "23", "396811": "11"}
          data = json_response( { :api_call => 'auction-values', :params => { :SPORT => "football",:source => source } } )[:body][:auction_values]
          # Convert it into a more useful format e.g. {:cbs_id=>"396134", :av_cbs=>"7"}
          data.each do |k,v|
            # Put these more useful hashes into the array
            auction_values << {:id => k.to_s, "av_#{source}".to_sym => v }
          end
        end
        # Return the array
        auction_values
      end
  end
  
  class UsersAndDrafts
    
    # params is a set of params with symbolized_keys! for use in development # Updated 8/31/2012
    # params = {"access_token"=>"U2FsdGVkX19BZczZgzxwaKawHs15NSSb9bbJKqElEwMTh1CrTcqVjFDhmGaZkpv7GUfzPjMhP6DkFPRgAzko16iKOpk4KlDQb12EgfuDBzHGRvvMePudLxMnMJtJ2E8O", "user_id"=>"b2c7c77e1b22e0f4", "SPORT"=>"football", "league_id"=>"3531-h2h", "controller"=>"drafts", "action"=>"show"}.symbolize_keys!
    # Cbs::League.build_hash_league_details("U2FsdGVkX19BZczZgzxwaKawHs15NSSb9bbJKqElEwMTh1CrTcqVjFDhmGaZkpv7GUfzPjMhP6DkFPRgAzko16iKOpk4KlDQb12EgfuDBzHGRvvMePudLxMnMJtJ2E8O").merge(Cbs::League.build_hash_draft_config("U2FsdGVkX19BZczZgzxwaKawHs15NSSb9bbJKqElEwMTh1CrTcqVjFDhmGaZkpv7GUfzPjMhP6DkFPRgAzko16iKOpk4KlDQb12EgfuDBzHGRvvMePudLxMnMJtJ2E8O"))
    # Cbs::League.build_hash_fantasy_teams("U2FsdGVkX19BZczZgzxwaKawHs15NSSb9bbJKqElEwMTh1CrTcqVjFDhmGaZkpv7GUfzPjMhP6DkFPRgAzko16iKOpk4KlDQb12EgfuDBzHGRvvMePudLxMnMJtJ2E8O")
    # Cbs::League.build_slots_array("U2FsdGVkX19BZczZgzxwaKawHs15NSSb9bbJKqElEwMTh1CrTcqVjFDhmGaZkpv7GUfzPjMhP6DkFPRgAzko16iKOpk4KlDQb12EgfuDBzHGRvvMePudLxMnMJtJ2E8O")
    # Cbs::League.build_hash_draft_order("U2FsdGVkX19BZczZgzxwaKawHs15NSSb9bbJKqElEwMTh1CrTcqVjFDhmGaZkpv7GUfzPjMhP6DkFPRgAzko16iKOpk4KlDQb12EgfuDBzHGRvvMePudLxMnMJtJ2E8O")
    def self.upsert_all(options = {}) # e.g. {"access_token"=>"U2FsdGVkX19BZczZgzxwaKawHs15NSSb9bbJKqElEwMTh1CrTcqVjFDhmGaZkpv7GUfzPjMhP6DkFPRgAzko16iKOpk4KlDQb12EgfuDBzHGRvvMePudLxMnMJtJ2E8O", "user_id"=>"b2c7c77e1b22e0f4", "SPORT"=>"football", "league_id"=>"3531-h2h", "controller"=>"drafts", "action"=>"show"}
      cbs_id = options.fetch(:cbs_id)
      access_token = options.fetch(:access_token)

      # API responses assigned to local variables
      league_attributes = Cbs::League.build_hash_league_details(access_token).merge(Cbs::League.build_hash_draft_config(access_token))
      teams_attributes = Cbs::League.build_hash_fantasy_teams(access_token)
      slots_attributes = Cbs::League.build_slots_array(access_token)
      rounds_attributes = Cbs::League.build_hash_draft_order(access_token)

      # find or create user
      user = User.find_or_create_by_cbs_id( cbs_id )

      # find or create draft # bug: does not allow for users with more than one draft. Possible solution: match by user_id and name
      draft = Draft.find_or_create_by_user_id( user.id ) 
      draft_id = draft.id
    
      # find or create and update league
      league_attributes[:draft_id] = draft_id
      league = League.find_or_create_by_draft_id( draft_id )
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
         owners_attr.map! do |owner_attr|
           owner_attr[:team_id] = Team.where( :owner_hex_id => owner_attr[:cbs_hex_id])[0].id
           owner_attr[:created_at] = Time.now
           owner_attr[:updated_at] = Time.now
           owner_attr
         end
       end
          
       UpdatesAndInserts.upsert( Owner, teams_owners_attributes.flatten!, :cbs_hex_id )
    
      #iterate over teams in the league to create upsert slot rows
      teams = Team.where( :league_id => league_id )
      # binding.pry
      teams.each do |team|
        slots = slots_attributes

        team_id = team.id
        number = 1

        slots.map! do |slot_attr|  # slots_attributes now returns an array instead of {:slots_attributes => [] }
          slot_attr[:number] = number
          slot_attr[:team_id] = team_id
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