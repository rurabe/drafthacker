class Pick < ActiveRecord::Base
  belongs_to :player
  belongs_to :team
  belongs_to :round
  attr_accessible :number,
  								:team_info,      # eg 8
  								:team_id, 			 # eg 7265
  								:round_id, 
  								:player_id

  #after_create :match_team_id



  private

  	def match_team_id
  		team = Team.find_by_league_team_id(self.team[:id]).where(:league_id => self.round.draft.league)
  		self.team_id = team.id
  	end
end
