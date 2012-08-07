require 'spec_helper'

describe "UserAuthenication" do
 
  before :each do
	visit new_user_registration_path
	@email = Faker::Internet.email 
	fill_in "Email", :with => @email 
	fill_in "Password", :with => "password"
	fill_in "user_password_confirmation", :with => "password"
	click_button "Sign up"
  end 

  context "A user signs up" do
    it "allows a user to sign up with our site" do
    	User.find_by_email(@email).should be
    end
  end

  context "A user signs out" do 
  	it "allows a user to sign out at any time" do
  		click_button "Sign out"
  		current_user.should_not be
  	end
  end

end
