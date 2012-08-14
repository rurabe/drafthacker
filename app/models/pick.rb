class Pick < ActiveRecord::Base
  belongs_to :player
  belongs_to :team
  belongs_to :round
  belongs_to :draft
  attr_accessible :number,
                  :league_team_id,  # eg 10 - This one is league specific
                  :team_id,          # eg 483
                  :draft_id,
                  :player_id


  #after_create :link_team_id



  private
    def link_team_id
      team = Team.where(:league_id => self.round.draft.league, :league_team_id => self.league_team_id).first
      self.update_attributes(:team_id => team.id)
    end
end
