class Slot < ActiveRecord::Base
  belongs_to :team
  belongs_to :player

  attr_accessible :eligible_positions

end
