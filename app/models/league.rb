class League < ActiveRecord::Base
  belongs_to :draft
  has_many :teams
  attr_accessible :name,
                #API data
                  :regular_season_periods,
                  :playoff_periods,
                  :season_status,
                  :name,
                  :draft_type,
                  :num_divisions,
                  :uses_keepers,
                  :num_teams,
                  :commish_type,
                  :use_robot,
                  :time,
                  :date,
                  :order_type,
                  :order_source,
                  :auction_supplemental_rounds,
                  :timer_start,
                  :pick_email,
                  :draft_event_type,
                  :draft_schedule,
                  :rounds,
                  :time_limit,
                  :timer_end

  validates_presence_of :draft_id, :rounds, :num_teams


private

  def create_teams
    # self.num_teams.times do
  end

end
