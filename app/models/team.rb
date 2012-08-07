class Team < ActiveRecord::Base
  belongs_to :user
  has_many :players

  attr_accessible :name
  validates :name, :uniqueness => true
  validates :user_id, :presence => true
end
