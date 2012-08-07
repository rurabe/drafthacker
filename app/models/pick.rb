class Pick < ActiveRecord::Base
  belongs_to :player
  belongs_to :team
  belongs_to :round
  # attr_accessible :title, :body
end
