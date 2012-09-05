class Round < ActiveRecord::Base
  belongs_to  :draft
  has_many    :picks

  attr_accessible :number,
                  :draft_id 

end
