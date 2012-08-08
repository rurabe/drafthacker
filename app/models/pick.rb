class Pick < ActiveRecord::Base
  has_one     :player
  has_one     :team
  belongs_to  :round
end
