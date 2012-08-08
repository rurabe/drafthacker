require 'spec_helper'

describe Draft do
  it { should belong_to :user }
  it { should have_one :league }
  it { should validate_presence_of :user_id }

  describe "upon creation" do
    it "creates a league" do
      user = User.create
      @draft = user.drafts.new
      @draft.league.should_not be
      @draft.save
      @draft.league.should be
    end
  end

end
