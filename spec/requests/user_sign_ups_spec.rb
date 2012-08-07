require 'spec_helper'
#include Devise::TestHelpers

describe Devise::SessionsController do

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
    		click_link "Sign out"
    		page.should have_content "Sign in"
    	end
    end

  end
end
