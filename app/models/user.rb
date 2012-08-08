class User < ActiveRecord::Base
  attr_accessible :cbs_id
  has_many :drafts
  has_one :team
  after_create :create_draft

  private

  def create_draft
    draft = self.drafts.build
    unless draft.save
      raise "after_create callback failed to create a draft from the User class."
    end
  end


end
