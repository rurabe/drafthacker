class Draft < ActiveRecord::Base
  belongs_to :user
  has_one :league
  attr_accessible :name, :start_time, :league_attributes
  validates_presence_of :user_id

  accepts_nested_attributes_for :league
end
