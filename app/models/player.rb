class Player < ActiveRecord::Base
  belongs_to :team
  attr_accessible :name

end
