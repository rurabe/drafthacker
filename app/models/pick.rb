class Pick < ActiveRecord::Base
  belongs_to :player
  belongs_to :team
  belongs_to :round
  attr_accessible :number,
                  :team_info,
                  :team_id    # eg 8


  after_commit :link_team_id



  private

    def link_team_id
      team = Team.where(:league_id => self.round.draft.league, :league_team_id => self.league_team_id)
      self.update_attributes(team)
    end
end
