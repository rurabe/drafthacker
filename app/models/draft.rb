class Draft < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :start_time
end
