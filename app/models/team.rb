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
                  :slots_attributes

  accepts_nested_attributes_for :slots

  after_commit :link_to_user

  private

  def link_to_user
    self.league.draft.user.team = self if self.logged_in_team
  end
end
