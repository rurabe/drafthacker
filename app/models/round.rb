class Round < ActiveRecord::Base
  belongs_to  :draft
  has_many    :picks

  accepts_nested_attributes_for :picks
  attr_accessible :picks_attributes
end
