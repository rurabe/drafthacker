class Draft < ActiveRecord::Base
  belongs_to :user
  has_one :league
  has_many :teams, :through => :league
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
      this_draft = Draft.where(:id => self).includes(:picks,:teams).first

        this_draft.teams.each do |team|
          team_picks = this_draft.picks.where(:league_team_id => team.league_team_id)

          team_picks.each do |pick| 
            pick.team = team
            pick.draft = self
          end
        end
      self.save
    end

  end
