class Round < ActiveRecord::Base
  belongs_to  :draft
  has_many    :picks

  attr_accessible :number,
                  :picks_attributes,
                  :draft_id #
  # accepts_nested_attributes_for :picks


end
