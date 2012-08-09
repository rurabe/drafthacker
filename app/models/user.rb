class User < ActiveRecord::Base
  has_many :drafts
  has_one :team

  accepts_nested_attributes_for :drafts
  attr_accessible :cbs_id, :drafts_attributes

end
