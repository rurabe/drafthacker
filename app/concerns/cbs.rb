require 'net/http'
module Cbs

  module ApiCall #--------------------------------------------------------------------------------------------------------

    def json_response(options = {}) #eg { :api_call => 'league/details', :params => { :access_token => "csugvwu3298hfw9" } }
      JSON.parse(read_response(options), :symbolize_names => true)
    end

    private

      def read_response(options = {})
        Net::HTTP.get_response(build_url(options)).body
      end

      def build_url(options = {})
        api_call = options.fetch(:api_call)       # eg. 'league/details', !!-REQUIRED-!!
        params = build_params(options[:params]) if options[:params]   # eg. { :SPORT => "football" }, optional

        URI("http://api.cbssports.com/fantasy/#{api_call}?#{params}response_format=JSON")
      end

      def build_params(params = {}) # eg. { :SPORT => "football" }
        param_string = []
        params.each do |k,v|
          param_string << "#{k.to_s}=#{v}&"
        end
        param_string.join("")
      end
  end

  class Import

    def self.batch_create_all(options = {})
      cbs_id = options.fetch(:cbs_id)
      access_token = options.fetch(:access_token)

      # API responses assigned to local variables
      league_attributes = Cbs::League.build_hash_league_details(access_token).merge(Cbs::League.build_hash_draft_config(access_token))
      teams_attributes = Cbs::League.build_hash_fantasy_teams(access_token)
      slots_attributes = Cbs::League.build_slots_array(access_token)
      rounds_attributes = Cbs::League.build_hash_draft_order(access_token)

      # create user
      user = User.create(:cbs_id => cbs_id)

      # create draft
      # drafts_attributes =
      # draft = user.drafts.first.build
      draft = ActiveRecord::Draft.create(:user_id => user.id)
      # create league
      league_attributes[:draft_id] = draft.id
      league = ActiveRecord::League.create(league_attributes)

      # build_and_import_teams_and_owners(user_id)
      teams = []
      teams_owners_attributes = []
      teams_slots_attributes = []

      # strips team_attributes of owners_attributes and slots_attributes
      # instantiates new Team objects and stores them in teams array
      teams_attributes.each do |team_attr|
        owners = []
        teams_owners_attributes << team_attr.delete(:owners_attributes)
        teams_slots_attributes << team_attr.delete(:slots_attributes)
        team_attr[:league_id] = league.id
        # team_attr[:user_id] = user.id
        team = Team.new(team_attr)
        teams <<  team
      end
      # import teams
      # puts teams.map{|team| team.class}
      # == Examples
          #  class BlogPost < ActiveRecord::Base ; end
          #
          #  # Example using array of model objects
          #  posts = [ BlogPost.new :author_name=>'Zach Dennis', :title=>'AREXT',
          #            BlogPost.new :author_name=>'Zach Dennis', :title=>'AREXT2',
          #            BlogPost.new :author_name=>'Zach Dennis', :title=>'AREXT3' ]
          #  BlogPost.import posts
      t = teams_attributes.map{|team_attr| "Team.new(#{team_attr})"}

      Team.import(teams, :synchronize => teams)

      all_owners = []
      all_slots = []
      #iterate over teams to create owner and slot objects
      teams.length.times do |i|
        owners = []
        slots = []
        team = teams[i]
        owners_attributes = teams_owners_attributes[i]
        slots_attributes = teams_slots_attributes[i]

        #build owners for team
        owners_attributes.each do |owner_attr|
          owner_attr[:team_id] = team.id
          owner = Owner.new(owner_attr)
          owners << owner
        end

        # build_slots for team
        slots_attributes.each do |slot_attr|
          slot_attr[:team_id] = team.id
          slots << Slot.new(slot_attr)
        end

      end

        all_owners << owners
        all_slots << slots

        # import owners and slots
        Owner.import(all_owners.flatten!)
        Slot.import(all_slots.flatten!)

      #def build_and_import_rounds_and_picks
      rounds = []
      picks = []
      rounds_attributes.each do |round_attr|
        pick_attributes = round_attr.delete(:picks_attributes)
        round_attr[:draft_id] = draft.id
        round = Rounds.new(round_attr)
        rounds << round
        pick_attributes.each do |pick_attr|
          pick_attr[:round_id] = round.id
          pick_attr[:draft_id] = draft.id
          pick = Pick.new(pick_attr)
          picks << pick
        end
      end
      Round.import(rounds)
      Pick.import(picks)

    end
  end

  class Draft #--------------------------------------------------------------------------------------------------------
    extend ApiCall

    # Updates Draft Results
    def self.update( options = {} ) #eg. { :access_token => "vksdhgvkhsdbvksdiugweiufgwiusd", :draft_id => 6362 }
      # Setting variables from the options
      draft_id = options.fetch(:draft_id)
      access_token = options.fetch(:access_token)

      # Get the JSON from the API
      status = json_response( { :api_call => 'league/draft/results', :params => { :access_token => access_token } } ) [:body][:draft_results]

      # Set players to picks and picks to slots
      status[:picks].each do |pick|
        system_pick = Pick.where(:draft_id => draft_id , :number => pick[:overall_pick]).first
        system_pick.update_attributes(:player_id => pick[:player][:id])

        #links picks to slots. needs refactoring and more testing
        slots = system_pick.team.slots.where(:eligible_positions => pick[:player][:position], :player_id => nil)
        if !system_pick.team.slots.pluck(:player_id).include?(pick[:player][:id].to_i)
          if !slots.empty?
            slots.first.update_attributes(:player_id => pick[:player][:id])
          else
            slot = system_pick.team.slots.where(:eligible_positions => "RS", :player_id => nil).first
            slot.update_attributes(:player_id => pick[:player][:id]) if slot
          end
        end
      end
    end
  end

  class Players #--------------------------------------------------------------------------------------------------------
    extend ApiCall

    def self.populate_all
      populate
      populate_adp
      populate_auction_values
    end

    # Populates the db with all players or updates them if they already exist. Approximately 2827 total.
    def self.populate
      players = json_response( { :api_call => 'players/list', :params => { :SPORT => "football" } } )[:body][:players]
      update_or_create(players)
    end

    # Adds ADP information to Players
    def self.populate_adp
      players = json_response( { :api_call => 'players/average-draft-position', :params => { :SPORT => "football" } } )[:body][:average_draft_position][:players]
      update_or_create(players)
    end

    #Adds Auction Values to Players
    def self.populate_auction_values
      # A brief discussion of these can be found at http://fantasynews.cbssports.com/fantasyfootball/rankings
      update_or_create(build_auction_values,false)
    end



    private
      def self.update_or_create(players,needs_cleaning=true)
        # Take each player hash
        players.each do |player|
          # Clean the hash for reserved words and to match our schema
          clean_hash(player) if needs_cleaning
          # Where tries to find the object in the current records. If nil, it creates a new one.
          player_obj = Player.where(:id => player[:id]).first_or_initialize(player)
          # If the record is not new, run update attributes on it.
          player_obj.update_attributes(player) if !player_obj.new_record?
          # If it is a new object, save the record (since update_attributes saves by default)
          player_obj.save if player_obj.new_record?
        end
      end

      def self.clean_hash(hash)
        #Certain keys from the CBS JSON response need to be reassigned for reserved words, conflicts, etc.
        hash[:first_name] = hash.delete :firstname
        hash[:last_name] = hash.delete :lastname
        hash[:full_name] = hash.delete :fullname
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
          # Convert it into a more useful format
          data.each do |k,v|
            # Put these more useful hashes into the array
            auction_values << {:id => k.to_s, "av_#{source}".to_sym => v }
          end
        end
        # Return the array
        auction_values
      end

  end



  class League #--------------------------------------------------------------------------------------------------------
    extend ApiCall

    def self.build_mega_hash(options = {}) # eg. { :access_token => "csugvwu3298hfw9", :cbs_id => "r29hefb298f2b" }
      cbs_id = options.fetch(:cbs_id)
      access_token = options.fetch(:access_token)

      { :cbs_id => cbs_id,
        :drafts_attributes =>
          [
            {
              :league_attributes =>
                  build_hash_league_details(access_token).merge(build_hash_draft_config(access_token)).merge(
                  :teams_attributes => build_hash_fantasy_teams(access_token)),
              :rounds_attributes =>
                build_hash_draft_order(access_token)
            }
          ]
      }
    end

    # private


      # API call to http://api.cbssports.com/fantasy/league/details ------------------------------
      def self.build_hash_league_details(access_token)
        details = json_response({ :api_call => 'league/details', :params => { :access_token => access_token } })[:body][:league_details]
        # Type is a reserved word in ActiveRecord
        details[:commish_type] = details.delete :type
        details
      end

      # API call to http://api.cbssports.com/fantasy/league/draft/config ------------------------------
      def self.build_hash_draft_config(access_token)
        configurations = json_response({ :api_call => 'league/draft/config', :params => { :access_token => access_token } })[:body][:draft]
        # Type is a reserved word in ActiveRecord
        configurations[:draft_event_type] = configurations.delete :type
        configurations
      end

      # API call to http://api.cbssports.com/fantasy/league/teams ------------------------------
      def self.build_hash_fantasy_teams(access_token)
        teams = json_response({ :api_call => 'league/teams', :params => { :access_token => access_token } })[:body][:teams]
        # Create the slot array that gets assigned to each team
        team_slots_array = build_slots_array(access_token)

        teams.map! do |team|
          # Id is already an attribute of team
          team[:league_team_id] = team.delete :id

          # Rename 'owners' subhash to 'owners_attributes' to trigger the construction of nested attribtues
          team[:owners_attributes] = team.delete :owners

          # Rename 'id' to 'cbs_hex_id'. Side note: Why does CBS have so many id's? CBS: Just pick one and run with it.
          team[:owners_attributes].each { |owner| owner[:cbs_hex_id] = owner.delete :id }

          # Each team gets an slot array built for them
          team.merge team_slots_array
        end

        teams
      end
          # API call to http://api.cbssports.com/fantasy/league/rules ------------------------------
          def self.build_slots_array(access_token)
            rules = json_response({ :api_call => 'league/rules', :params => { :access_token => access_token } })[:body][:rules]
            slots_array = []

            # Select each *active* position hash eg {:abbr = > "QB", :max_total = > "No Limit", :max_active = > "1", :min_active = > "1"}
            rules[:roster][:positions].each do |hash|
              # Create the number of slots for that position
              hash[:max_active].to_i.times do
                slots_array << { :eligible_positions => hash[:abbr] }
              end
            end

            # Select the statuses section of the hash to determine the number of bench spots (RS) and make that many
            # eg : statuses = > [..., {:min = > "0", :max = > "6", :description = > "Reserve Players" }, ...]
            rules[:roster][:statuses][1][:max].to_i.times do
              slots_array << { :eligible_positions => "RS" }
            end

            { :slots_attributes => slots_array }
          end

      # API call to http://api.cbssports.com/fantasy/league/draft/order ------------------------------
      def self.build_hash_draft_order(access_token)
        all_picks = json_response({ :api_call => 'league/draft/order', :params => { :access_token => access_token } })[:body][:draft_order][:picks]
        rounds = []

        all_picks.each do |pick|
          # Team is already an association for a pick, plus all we need is the league_team_id
          pick[:league_team_id] = pick[:team][:id]
          pick.delete :team
        end

        # Select the number of rounds...
        num_of_rounds = all_picks[-1][:round].to_i

        # ...and make that many round hashes
        num_of_rounds.times do |i|
          # Select all picks for that given round
          round_picks = all_picks.select { |pick| pick[:round] == i+1 }

          # Delete attribute round from the pick hash. Prevents namespace conflict with pick's association to a round. round_id is accessible through the association.
          round_picks.each { |pick| pick.delete :round }

          # Assign a round number, and attach associated picks before pushing to rounds array.
          rounds << { :number => i+1, :picks_attributes =>  round_picks }
          end

        rounds
      end



  end
end