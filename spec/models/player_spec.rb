require 'spec_helper'

describe Player do

  it { should have_many :slots }

  context 'full_name attribute' do
    it 'can be mass assigned' do
      expect{ Player.create(:full_name => Faker::Name.name) }.to_not raise_error("ActiveModel::MassAssignmentSecurity::Error: Can\'t mass-assign protected attributes: name")
    end
  end

  context 'team_id attribute' do
    it 'cannot be mass assigned'
  end
end
