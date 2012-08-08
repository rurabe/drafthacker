class Draft < ActiveRecord::Base
  belongs_to :user
  has_one :league
  attr_accessible :name, :start_time
  validates_presence_of :user_id
end
