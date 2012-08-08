class User < ActiveRecord::Base
  attr_accessible :cbs_id
  has_many :drafts
  has_one :team


end
