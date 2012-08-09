class Team < ActiveRecord::Base
  belongs_to  :league
  belongs_to  :user
  has_many    :slots
  has_many    :players, :through => :slots

  attr_accessible :name
  validates :name, :uniqueness => true
  #validates :user_id, :presence => true
end
