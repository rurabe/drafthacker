class User < ActiveRecord::Base
  attr_accessible :cbs_id, :drafts_attributes
  has_many :drafts
  has_one :team

  accepts_nested_attributes_for :drafts
end
