require 'spec_helper'

describe League do
  it { should belong_to :draft }
  it { should have_many :teams }
  it { should validate_presence_of :draft_id }
  it { should validate_presence_of :num_teams }
  it { should validate_presence_of :rounds }

  describe "upon creation" do

    before :each do
      @league = User.create.drafts.first.league
    end

    it "creates new teams" do
      @league.teams.count.should > 0
    end
  end
end
