 class Team < ActiveRecord::Base
  belongs_to  :league
  belongs_to  :user
  has_many    :slots
  has_many    :players, :through => :slots
  has_many    :picks

  attr_accessible :long_abbr,
                  :logged_in_team,
                  :short_name,
                  :name,
                  :logo,
                  :abbr,
                  :owners,
                  :league_team_id, #CBS reports this as 'id'
                  :slots_attributes,
                  :picks

  accepts_nested_attributes_for :slots

  after_create :link_to_user, :link_to_picks

  private

  def link_to_user
    self.league.draft.user.team = self if self.logged_in_team
  end

  def link_to_picks
      # self.league.draft.rounds.each do |round|
      #   audit "#{round}"
      #   round.picks.each do |pick|
      #     audit "#{self.league_team_id}"
      #     pick.team = self
      #   end
      # end
      audit "THIS SHIT RUNS"
    end

end
