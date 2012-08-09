class Pick < ActiveRecord::Base
  belongs_to :player
  belongs_to :team
  belongs_to :round
  attr_accessible :team_id, :round_id, :player_id
end
