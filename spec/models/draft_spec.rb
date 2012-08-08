require 'spec_helper'

describe Draft do
  it { should belong_to :user }
  it { have_one :league }
  it { should validate_presence_of :user_id }

  describe "upon creation" do
    it "creates a league" do
      @draft = Draft.new(:user_id => 1)
      @draft.league.should_not be
      @draft.save
      @draft.league.should be
    end
  end

end
