class Draft < ActiveRecord::Base
  belongs_to :user
  has_one :league
  attr_accessible :name, :start_time


end
