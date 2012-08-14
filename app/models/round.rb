class Round < ActiveRecord::Base
  belongs_to  :draft
  has_many    :picks

  attr_accessible :number,
  								:picks_attributes
  accepts_nested_attributes_for :picks

  after_create :link_picks_to_draft
  

  private

  	def link_picks_to_draft
  		self.picks.each do |pick|
  			pick.draft = self.draft
  		end
  	end
end
