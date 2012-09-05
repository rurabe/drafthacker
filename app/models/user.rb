class User < ActiveRecord::Base
  has_many :drafts
  has_one :team

  attr_accessible :cbs_id

end
