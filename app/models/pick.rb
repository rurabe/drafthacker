class Pick < ActiveRecord::Base
  belongs_to :player
  belongs_to :team
  belongs_to :round
  attr_accessible :number,
                  :league_team_id,  # eg 10 - This one is league specific
                  :team_id          # eg 483


  after_create :link_team_id



  private
    def link_team_id
      team = Team.where(:league_id => self.round.draft.league, :league_team_id => self.league_team_id).first
      self.update_attributes(:team_id => team.id)
    end
end
