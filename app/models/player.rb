class Player < ActiveRecord::Base
  has_many :slots
  has_many :teams, :through => :slots
  has_many :picks

                  #cbs players api data:
  attr_accessible :cbs_id,
                  :first_name,
                  :full_name,
                  :icons,
                  :last_name,
                  :on_waivers,
                  :position,
                  :pro_status,
                  :pro_team,
                  :bye_week,
                  :is_locked,
                  :opponent,
                  :high,
                  :low,
                  :profile_link,
                  :pct,
                  :change,
                  :avg,
                  :profile_url,
                  :rank

end
