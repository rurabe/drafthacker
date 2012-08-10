require 'net/http'
module Cbs



  class Players
    def self.populate
        parsed_data = parse('http://api.cbssports.com/fantasy/players/list?SPORT=football&response_format=JSON')
        all_players = parsed_data[:body][:players]

        @key_conversion_hash = {
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


        all_players.each do |player|
          attributes = convert_keys(player, @key_conversion_hash)
          create_player_by_position_type(player[:position], attributes)
        end
      end

    private

    def self.convert_keys(hash, key_conversion_hash)
      new_hash = {}
      hash.each do |k, v|
        new_hash[key_conversion_hash[k]] = hash[k]
      end
      new_hash
    end


    def self.create_player_by_position_type(position, attributes)

      position_to_object_hash = {
                                  "D"         => lambda { Defense.create(attributes) },
                                  "DB"        => lambda { DefensiveBack.create(attributes) },
                                  "DL"        => lambda { DefensiveLineman.create(attributes) },
                                  "DST"       => lambda { DefenseSpecialTeams.create(attributes) },
                                  "K"         => lambda { Kicker.create(attributes) },
                                  "LB"        => lambda { Linebacker.create(attributes) },
                                  "QB"        => lambda { Quarterback.create(attributes) },
                                  "RB"        => lambda { RunningBack.create(attributes) },
                                  "ST"        => lambda { SpecialTeams.create(attributes) },
                                  "TE"        => lambda { TightEnd.create(attributes) },
                                  "TQB"       => lambda { TeamQuarterback.create(attributes) },
                                  "WR"        => lambda { WideReceiver.create(attributes) },
                                  "FLEX"      => lambda { Player.create(attributes) },
                                  "ID"        => lambda { Player.create(attributes) },
                                  "WR-TE"     => lambda { Player.create(attributes) },
                                  "RB-WR"     => lambda { Player.create(attributes) },
                                  "RB-WR-TE"  => lambda { Player.create(attributes) },
                                  "DL-LB-DB"  => lambda { Player.create(attributes) }
                                }

      position_to_object_hash[position].call

    end

    def self.parse(path)
      data = Net::HTTP.get_response(URI(path)).body
      JSON.parse(data, :symbolize_names => true)
    end
  end

  class League
    #User.new(CBS::League.create_or_update())
    #User.update_attributes(CBS::League.create_or_update())

    def self.params(access_token,cbs_id)
      @@access_token = access_token
      @@cbs_id = cbs_id

      build_mega_hash
    end

    def self.build_mega_hash
      {:cbs_id => @@cbs_id,
        :drafts_attributes =>
          [
            {
              :league_attributes =>
                  build_hash_league_details.merge(build_hash_draft_config).merge(
                  :teams_attributes => build_hash_fantasy_teams),
              :rounds_attributes =>
                build_hash_draft_order
            }
          ]
      }
    end

    def self.build_hash_league_details
      response = json_response('league/details')[:body][:league_details]
      response[:commish_type] = response[:type]
      response.delete :type
      @@league_details = response
    end

    def self.build_hash_draft_config
      response = json_response('league/draft/config')[:body][:draft]
      response[:draft_event_type] = response[:type]
      response.delete :type
      @@draft_config = response
    end

    def self.build_hash_draft_order
      response = json_response('league/draft/order')[:body][:draft_order][:picks]
      rounds = []
      @@draft_config[:rounds].to_i.times do |i|
        rounds << { :number => i+1, :picks_attributes =>  response.select { |pick| pick[:round] == i+1 } }
      end
      rounds
    end

    def self.build_hash_fantasy_teams
      response = json_response('league/teams')[:body][:teams]
      new_hash = {}
      response.map! do |team|
        team[:league_team_id] = team.delete :id
        team.merge build_slots_array
      end
      response
    end

    def self.build_hash_league_rules
      json_response('league/rules')[:body][:rules]
    end

    def self.build_slots_array
      response = build_hash_league_rules
      slots_array = []
      response[:roster][:positions].each do |hash|
        hash[:max_active].to_i.times do
          slots_array << { :eligible_position => hash[:abbr] }
        end
      end
      response[:roster][:statuses][1][:max].to_i.times do
        slots_array << { :eligible_positions => "RS" }
      end
      { :slots_attributes => slots_array }
    end

    def self.json_response(api_call)
      JSON.parse(read_response(api_call), :symbolize_names => true)
    end

    def self.read_response(api_call)
      Net::HTTP.get_response(build_url(api_call)).body
    end

    def self.build_url(api_call)
      URI("http://api.cbssports.com/fantasy/#{api_call}?access_token=#{@@access_token}&response_format=JSON&SPORT=football")
    end
  end
end
# def rounds_and_picks
#   parsed_data = parse('http://api.cbssports.com/fantasy/league/draft/order?SPORT=football&response_format=JSON&access_token=U2FsdGVkX1-Sj855Oa9QwS41LUcDCCaFkEAYBU_-htOX1VAMnUzbo4ZFtx_Y_EflpOxk9ztMxFQD2bCvNGeJ5NK68I3-Az4ni1Dans02_yyVxIBI_-BUAKifINXHnrvz')
#   picks_data = parsed_data[:body][:draft_order][:picks]
# end
#
# positions_data = open('http://api.cbssports.com/fantasy/positions?SPORT=football&response_format=JSON').read
# parsed_position_data = JSON.parse(positions_data, :symbolize_names => true)
