class Player < ActiveRecord::Base
  has_many :slots
  has_many :teams, :through => :slots
  has_many :picks

                  #cbs players api data:
  attr_accessible :id,                
                  :first_name,
                  :full_name,
                  :icons_injury,
                  :icons_headline,
                  :last_name,
                  :on_waivers,         # Is this neccesary?   
                  :pro_status,
                  :pro_team,
                  :bye_week,
                  :is_locked,
                  :opponent,
                  :pct,                # ADP
                  :change,             # ADP
                  :avg,                # ADP
                  :position,           
                  :high,               # ADP
                  :low,                # ADP
                  :rank                # ADP

end
