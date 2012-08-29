class Team < ActiveRecord::Base
  belongs_to  :league
  belongs_to  :user
  has_many    :slots
  has_many    :players, :through => :slots
  has_many    :picks
  has_many    :owners

  attr_accessible :long_abbr,
                  :logged_in_team,
                  :short_name,
                  :name,
                  :logo,
                  :abbr,
                  :owners,
                  :league_team_id, #CBS reports this as 'id'
                  :slots_attributes,
                  :owners_attributes,
                  :league_id, #
                  :user_id #


  after_create :link_to_user

  def next_pick
    self.picks.where(:player_id => nil).order(:number).limit(1).first
  end

  private

    def link_to_user
      self.league.draft.user.team = self if self.logged_in_team
    end

end
