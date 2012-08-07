require 'spec_helper'

describe Player do

  context 'name attribute' do
    it 'can be mass assigned' do
      expect{ Player.create(:name => Faker::Name.name) }.to_not raise_error("ActiveModel::MassAssignmentSecurity::Error: Can\'t mass-assign protected attributes: name")
    end

  end

  context 'team_id attribute' do
    it 'cannot be mass assigned'

    it 'belongs to only one team'
  end

end
