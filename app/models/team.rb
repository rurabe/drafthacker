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
                  :owners_attributes

  accepts_nested_attributes_for :slots,
                                :owners

  after_create :link_to_user

  def get_players
    player_spot = []
    self.slots.order(:created_at).each do |s|
      player_spot << {:status => s.player ? s.player.full_name : '--',
                      :position => s.eligible_positions} 
    end
  end

  private

  def link_to_user
    self.league.draft.user.team = self if self.logged_in_team
  end

end
