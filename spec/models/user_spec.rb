require 'spec_helper'

describe User do
  it { should have_many :drafts }
  it { should have_one :team }

  describe "upon creation" do
    it "creates a new draft" do
      @user = User.new
      @user.drafts.count.should == 0
      @user.save
      @user.drafts.count.should == 1
    end

  end
end
