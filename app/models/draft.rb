class Draft < ActiveRecord::Base
  belongs_to :user
  has_one :league
  attr_accessible :name, :start_time
  validates_presence_of :user_id

  after_create :create_league


  private

    def create_league
      league = self.build_league(:num_teams=>10, :rounds=>"14")
      unless league.save
        raise "after_create failed to build a new league from the Draft class"
      end
    end
end
