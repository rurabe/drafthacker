class Round < ActiveRecord::Base
  belongs_to :draft
  # attr_accessible :title, :body
end
