class Player < ActiveRecord::Base
  belongs_to :slot
  attr_accessible :cbs_id,
                  :first_name,
                  :full_name,
                  :icons_headline,
                  :icons_injury,
                  :last_name,
                  :on_waivers,
                  :primary_position,
                  :pro_status,
                  :pro_team,
                  :bye_week,
                  :is_locked,
                  :opponent,
                  :team_id



end
