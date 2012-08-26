class League < ActiveRecord::Base
  belongs_to :draft
  has_many :teams

  # accepts_nested_attributes_for :teams
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
                  :timer_end,
                  :draft_state,
                  :timestamp,
                  :teams_attributes,
                  :draft_id #



end
