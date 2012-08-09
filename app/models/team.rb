class Team < ActiveRecord::Base
  belongs_to  :league
  belongs_to  :user
  has_many    :slots
  has_many    :players, :through => :slots
  has_many    :picks

  attr_accessible :name
  validates :name, :uniqueness => true
  validates :user_id, :presence => true

  after_save :create_slots

  def create_slots
    self.league.rounds.times do
      self.slots.create
    end
  end
end
