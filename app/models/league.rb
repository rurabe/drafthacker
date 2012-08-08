class League < ActiveRecord::Base
  belongs_to :draft
  attr_accessible :name
end
