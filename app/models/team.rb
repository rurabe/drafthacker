class Team < ActiveRecord::Base
  belongs_to  :league
  belongs_to  :user
  has_many    :slots
  has_many    :players, :through => :slots
  has_many    :picks

  attr_accessible :name, :slots_attributes
  accepts_nested_attributes_for :slots
end
