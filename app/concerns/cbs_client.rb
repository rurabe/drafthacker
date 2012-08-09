module CbsClient

require 'JSON'
require 'open-uri'

  class Populator
    def players
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

    def convert_keys(hash, key_conversion_hash)
      new_hash = {}
      hash.each do |k, v|
        new_hash[key_conversion_hash[k]] = hash[k]
      end
      new_hash
    end


    def create_player_by_position_type(position, attributes)

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

    def parse(path)
      data = open(path).read
      JSON.parse(data, :symbolize_names => true)
    end
  end
end

# def rounds_and_picks
#   parsed_data = parse('http://api.cbssports.com/fantasy/league/draft/order?SPORT=football&response_format=JSON&access_token=U2FsdGVkX1-Sj855Oa9QwS41LUcDCCaFkEAYBU_-htOX1VAMnUzbo4ZFtx_Y_EflpOxk9ztMxFQD2bCvNGeJ5NK68I3-Az4ni1Dans02_yyVxIBI_-BUAKifINXHnrvz')
#   picks_data = parsed_data[:body][:draft_order][:picks]
# end
#
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