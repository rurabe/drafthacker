module UpdatesAndInserts
  
  # Table of Contents
  # UsersAndDrafts
  #   def self.upsert_all
  #   def self.update_draft
  # Players
  #   def self.upsert_all
  #   def self.upsert_base
  #   def self.upsert_adp
  #   def self.upsert_auction_values
  # def self.upsert
  
  
  class UsersAndDrafts
    extend ApiCall
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
      user_id = user.id

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
        team_attr[:user_id] = nil
        
        if team_attr[:logged_in_team]
          team_attr[:user_id] = user_id
          team_attr.delete(:logged_in_team)
        end
        
        if team_attr[:owners_attributes][0]
          team_attr[:owner_hex_id] = team_attr[:owners_attributes][0][:cbs_hex_id] if team_attr[:owners_attributes][0][:cbs_hex_id]
        end
      
        # removes owners_attributes and slots_attributes
        teams_owners_attributes << team_attr.delete(:owners_attributes) if team_attr[:owners_attributes]
        team_attr.delete(:slots_attributes) if team_attr[:slots_attributes] # this should no longer be in the team_attributes hash
                
        team_attr
      end
          
      binding.pry
      
      UpdatesAndInserts.upsert( Team, teams_attributes, :league_id, :league_team_id )
     
      binding.pry
     
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
  

    def self.update_draft( options = {} ) #eg. { :access_token => "vksdhgvkhsdbvksdiugweiufgwiusd", :draft => #<Draft id: 142... > }
      # Setting variables out of the options hash
      draft = options.fetch(:draft)
      access_token = options.fetch(:access_token)
      cbs_league_id = options.fetch(:cbs_league_id)

      # Get the JSON from the API
      status = json_response( { :api_call => 'league/draft/results', :params => { :access_token => access_token, :league_id => cbs_league_id } } ) [:body][:draft_results]

      # Generate SHA hash from the response
      current_response_sha = Digest::SHA1.hexdigest(status.to_s)

      # Make Sure Api is new
      if draft.last_response_sha != current_response_sha

        # Find the picks that are new by selecting only those that are greater than the last pick.
        new_picks = status[:picks].select { |pick| pick[:overall_pick].to_i > draft.last_pick.to_i }
        if !new_picks.empty?
          picks_to_update = []
          slots_to_update = []
          # Set the newly drafted players to picks and picks to slots 
          new_picks.each do |pick|
                      
            # Select the pick that corresponds to the latest pick(s)
            system_pick = Pick.where(:draft_id => draft , :number => pick[:overall_pick]).first
            # Link that pick to the player indicated in the response using id
            picks_to_update << {:id => system_pick.id, :player_id => pick[:player][:id]}
            # system_pick.update_attributes(:player_id => pick[:player][:id]) # need to consolidate queries

            # Select all empty slots that this player could fill, and order it by id so he fills the first one.
            slots = system_pick.team.slots.where(:eligible_positions => pick[:player][:position], :player_id => nil).order(:id)
          
            # Check to see if there are any active slots
          
            # Check to see if there are any open active spots.
            if !slots.empty? # if there are slots accepting that position (have that eligible_position)
              # If so, link that player to the first one
              slot = slots.first
              slots_to_update << { :id => slot.id, :player_id => pick[:player][:id] }
              # slot.update_attributes(:player_id => pick[:player][:id]) # need to consolidate queries
            else 
              # Otherwise (if all of the slots accepting that position are filled), take the first RS slot
              slot = system_pick.team.slots.where(:eligible_positions => "RS", :player_id => nil).order(:id).first
              # And link him to that slot.
              slots_to_update << { :id => slot.id, :player_id => pick[:player][:id] }
              # slot.update_attributes(:player_id => pick[:player][:id]) if slot # need to consolidate queries
            end
          end

          # Updates the new Pick and Slot attributes using upsert
          UpdatesAndInserts.upsert(Pick, picks_to_update, :id)
          UpdatesAndInserts.upsert(Slot, slots_to_update, :id)
        
          # Update the draft with the latest response, and the number of picks completed.
          draft.update_attributes(:last_response_sha => current_response_sha, :last_pick => new_picks[-1][:overall_pick]) # single query
        
          # Return the response for the players updated.
          new_picks # why do we need to return new_picks??? why not just true? ~Sung

        else
          puts "No new picks."
          false 
        end
      else
        # Return false if no players have been drafted since the last check                                                                                                          
        false
      end
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
        UpdatesAndInserts.upsert( Player, players, :id)
      end

      def self.clean_player_hash(hash)
        # Certain keys from the CBS JSON response need to be reassigned for reserved words, conflicts, etc.
        # hash[:id]         = hash[:id]
        hash[:cbs_id]     = hash[:id] # might need to turn this into an integer
        hash[:first_name] = hash.delete :firstname  if hash[:firstname]
        hash[:last_name]  = hash.delete :lastname   if hash[:lastname]
        hash[:full_name]  = hash.delete :fullname   if hash[:fullname]
        hash[:created_at] = Time.now
        hash[:updated_at] = Time.now
        if hash[:icons]
          hash[:icons_headline] = hash[:icons][:headline]
          hash[:icons_injury] = hash[:icons][:injury]
          hash.delete :icons
        else
          hash[:icons_headline] = nil
          hash[:icons_injury] = nil
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

  private
  
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

end