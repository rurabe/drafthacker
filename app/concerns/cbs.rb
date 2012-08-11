require 'net/http'
module Cbs

  module ApiCall

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



  class Players
    extend ApiCall
    def self.populate
        players = json_response( { :api_call => 'players/average-draft-position', :params => { :SPORT => "football" } } )[:body][:average_draft_position][:players]

        players.each do |player|
          #Certain keys from the CBS JSON response need to be reassigned for reserved words, conflicts, etc.
          player[:cbs_id] = player.delete :id
          player[:first_name] = player.delete :firstname
          player[:last_name] = player.delete :lastname
          player[:full_name] = player.delete :fullname
          Player.create(player)
        end
    end

    # TODO update function
  end



  class League
    extend ApiCall

    # def self.params(options= {}) 
    #   build_mega_hash(options)
    # end

    def self.build_mega_hash(options = {}) # eg. { :access_token => "csugvwu3298hfw9", :cbs_id => "r29hefb298f2b" }
      cbs_id = options.fetch(:cbs_id)
      access_token = options.fetch(:access_token)

      { :cbs_id => options.fetch(:cbs_id),
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

    private


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
          # Team is already an association for a pick
          pick[:team_info] = pick.delete :team
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