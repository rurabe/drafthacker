module CbsClient

require 'json'
require 'open-uri'

  class Populator
    def players
      parsed_data = parse('http://api.cbssports.com/fantasy/players/list?SPORT=football&response_format=JSON')
      all_players = parsed_data[:body][:players]

      @conversion_hash = {
        :id         =>   :cbs_id,
        :firstname  =>   :first_name,
        :fullname   =>   :full_name,
        :icons      =>   :icons,
        :lastname   =>   :last_name,
        :on_waivers =>   :on_waivers,
        :position   =>   :primary_position,
        :pro_status =>   :pro_status,
        :pro_team   =>   :pro_team,
        :bye_week   =>   :bye_week,
        :is_locked  =>   :is_locked,
        :opponent   =>   :opponent
        }

      @opts = {
        "D" => Defense.create(@attributes),
        "DB" => DefensiveBack.create(@attributes),
        "DL" => DefensiveLineman.create(@attributes),
        "DST" => DefenseSpecialTeams.create(@attributes),
        "K" => Kicker.create(@attributes),
        "LB" => Linebacker.create(@attributes),
        "QB" => Quarterback.create(@attributes),
        "RB" => RunningBack.create(@attributes),
        "ST" => SpecialTeams.create(@attributes),
        "TE" => TightEnd.create(@attributes),
        "TQB" => TeamQuarterback.create(@attributes),
        "WR" => WideReceiver.create(@attributes)
      }

      all_players.each do |player|
        key = player(:position)
          player.each do |k, v|
            @attributes = {}
            @attributes[@conversion_hash[k]] = player[k]
          end
        @opts[key]
      end
    end

      def parse(path)
        data = open(path).read
        JSON.parse(data, :symbolize_names => true)
      end

      #  /players/player  A container for a player’s data.
      #  /players/player/@id  ID of a player.
      #  /players/player/firstname  The player’s first name.
      #  /players/player/fullname The player’s full name.
      #  /players/player/icons  A container element for the player’s update and injury icons.
      #  /players/player/icons/headline The headline of the player’s latest news update.
      #  /players/player/icons/injury If the player is injured, this field will exist and indicate the injury in the format: {injury}: {expected time of return}
      #  /players/player/lastname The player’s last name.
      #  /players/player/on_waivers A boolean to denote if a player is on waivers in a fantasy league or no.
      #  /players/player/position An abbreviation for the primary position of the player.
      #  /players/player/pro_status Specifies the roster status of the player on the player’s pro team.
      #  /players/player/pro_team An abbreviation for the player’s pro team.
      #  /players/player/bye_week A number to denote the bye-week for a pro team (only applicable to football).
      #  /players/player/is_locked  A boolean to denote if a player is locked (can not be involved in any add/drops, trades, and lineup moves as the player’s team’s game has already started).
      #  /players/player/opponent


      # positions_data = open('http://api.cbssports.com/fantasy/positions?SPORT=football&response_format=JSON').read
      # parsed_position_data = JSON.parse(positions_data, :symbolize_names => true)
  end

    # Some Shit
    def get_params#(access_token,cbs_id)
      @@access_token = "U2FsdGVkX18eAlAHs48KMkJOwSZuFyQY0cAKinkafQ9nG8p4AFzuCG14lXlV4pV-DAacLmwy7sToFRV5Sf7_DT8wyaedVv6TL_03czOPUFd4fNt9sJ-nWmTQsaOj88Br"
      @@cbs_id = "b2c7c77e1b22e0f4"

      # build_mega_hash
      build_hash_fantasy_teams



    end

    private

    # def build_mega_hash
    #   {:user => @@cbs_id,
    #     :drafts_attributes =>
    #       [
    #         {
    #           :league_attributes => 
    #             build_hash_league_details.merge(build_hash_draft_config).merge(build_hash_fantasy_teams) 

    #           :rounds_attributes =>
    #           [
    #             {
    #               :picks_attributes =>
    #               [
    #                 {

    #                 }
    #               ]
    #             }
    #           ]
    #         }
    #       ]
    #   }

    # end

    def build_hash_league_details
      response = json_response('league/details')[:body][:league_details]
      response[:commish_type] = response[:type] 
      response.delete :type
      @@league_details = response
    end

    def build_hash_draft_config
      response = json_response('league/draft/config')[:body][:draft]
      response[:draft_event_type] = response[:type] 
      response.delete :type
      @@draft_config = response
    end

    def build_hash_draft_order
      json_response('league/draft/order')
    end

    def build_hash_fantasy_teams
      response = json_response('league/teams')[:body][:teams]
      new_hash = {}
      response.map! do |team|
        team.merge build_slots_array
      end
      { :teams_attributes => response }
    end

    def build_hash_league_rules
      json_response('league/rules')[:body][:rules]
    end

    def build_slots_array
      response = build_hash_league_rules
      slots_array = []
      response[:roster][:positions].each do |hash|
        hash[:max_active].to_i.times do
          slots_array << { :eligible_position => hash[:abbr] } 
        end
      end
      response[:roster][:statuses][1][:max].to_i.times do 
        slots_array << { :eligible_position => "RS" } 
      end
      { :slots_attributes => slots_array }
    end

    def json_response(api_call)
      JSON.parse(read_response(api_call), :symbolize_names => true)
    end

    def read_response(api_call)
      open(build_url(api_call)).read
    end

    def build_url(api_call)
      "http://api.cbssports.com/fantasy/#{api_call}?access_token=#{@@access_token}&response_format=JSON"
    end
end

