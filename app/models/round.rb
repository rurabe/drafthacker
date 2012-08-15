class Round < ActiveRecord::Base
  belongs_to  :draft
  has_many    :picks

  attr_accessible :number,
  								:picks_attributes
  accepts_nested_attributes_for :picks


end
