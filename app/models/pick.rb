class Pick < ActiveRecord::Base
  belongs_to :player
  belongs_to :team
  belongs_to :round
  belongs_to :draft
  attr_accessible :number,
                  :league_team_id,  # eg 10 - This one is league specific
                  :team_id,          # eg 483
                  :draft_id,
                  :player_id,
                  :round_id,
                  :round_number


  def to_feed_item
    { :round => self.round.number,
      :pick => (self.number - 1) % self.team.league.num_teams + 1,
      :team => self.team.abbr,
      :player => "#{self.player.first_name[0]}. #{self.player.last_name}",
      :pro_team => self.player.pro_team,
      :position => self.player.position }
  end

end
