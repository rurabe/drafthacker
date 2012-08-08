module CbsClient

require 'json'
require 'open-uri'
def populate_everything
  populate_players
  populate_league
end

def parseUrlToJSON(path)
  data = open(path).read
  JSON.parse(data, :symbolize_names => true)
end

def populate_players
  parsed_data = parseUrlToJSON('http://api.cbssports.com/fantasy/players/list?SPORT=football&response_format=JSON')
  all_players = parsed_data[:body][:players]

  conversion_hash = {
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

  opts = {
    "D" => Defense.create(attributes),
    "DB" => DefensiveBack.create(attributes),
    "DL" => DefensiveLineman.create(attributes),
    "DST" => DefenseSpecialTeams.create(attributes),
    "K" => Kicker.create(attributes),
    "LB" => Linebacker.create(attributes)
    "QB" => Quarterback.create(attributes),
    "RB" => RunningBack.create(attributes),
    "ST" => SpecialTeams.create(attributes),
    "TE" => TightEnd.create(attributes),
    "TQB" => TeamQuarterback.create(attributes),
    "WR" => WideReceiver.create(attributes),
  }


  all_players.each do |player|
    key = player(:position)
    attributes = {}
      player.each do |k, v|
        attributes[conversion_hash[k]] = player[k]
      end
    opts[key]
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


  positions_data = open('http://api.cbssports.com/fantasy/positions?SPORT=football&response_format=JSON').read
  parsed_position_data = JSON.parse(positions_data, :symbolize_names => true)




  def create_players
  end

end

