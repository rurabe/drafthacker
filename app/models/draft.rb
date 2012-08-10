class Draft < ActiveRecord::Base
  belongs_to :user
  has_one :league
  has_many :rounds


  attr_accessible :name, 
  								:start_time, 
  								:league_attributes, 
  								:rounds_attributes
  accepts_nested_attributes_for :league, :rounds



end
