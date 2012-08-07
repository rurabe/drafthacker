require 'spec_helper'

describe Team do
  @name = Faker::Name.name
  let (:team) {Team.new(:name => @name)}

  it 'has many players'

  context 'name attribute' do
    it 'can be mass assigned' do
      expect{ team }.to_not raise_error("ActiveModel::MassAssignmentSecurity::Error: Can\'t mass-assign protected attributes: name")
    end

    it "is unique" do
      team.save
      Team.new(:name => @name ).should_not be_valid
    end

  end

  context 'user_id attribute' do
    it 'cannot be mass assigned' do
      expect {Team.new(:name => @name, :user_id => 1) }.to raise_error
    end

    it 'cannot be null'

    it 'belongs to only one user'
  end
end
