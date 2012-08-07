require 'spec_helper'

describe "NewDrafts" do

	before :each do
    	visit new_user_registration_path
    	email = Faker::Internet.email 
    	fill_in "Email", :with => email 
    	fill_in "Password", :with => "password"
    	fill_in "user_password_confirmation", :with => "password"
    	click_button "Sign up"
    end

  describe "A user may have the option to create a new draft" do
    it "takes the user to a draft creation page when they click new draft" 
 
  end
end
