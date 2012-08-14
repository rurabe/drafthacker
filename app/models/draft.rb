class Draft < ActiveRecord::Base
  belongs_to :user
  has_one :league
  has_many :rounds
  has_many :picks, :through => :rounds


  attr_accessible :name, 
  								:start_time, 
  								:league_attributes, 
  								:rounds_attributes
  								
  accepts_nested_attributes_for :league, 
  															:rounds


  after_create :link_teams_to_picks

  private

    def link_teams_to_picks
      teams = self.league.teams

      self.rounds.each do |round|
        round.picks.each do |pick|
          this_pick_team = teams.where(:league_team_id => pick.league_team_id).first
          pick.team_id = this_pick_team.id
        end
      end
      self.save
    end

  end
