require 'spec_helper'

describe Team do

  it 'has many players'

  context 'name attribute' do
    it 'can be mass assigned' do
      expect{ Team.create(:name => "Badass") }.to_not raise_error("ActiveModel::MassAssignmentSecurity::Error: Can\'t mass-assign protected attributes: name")
    end

    it "is unique"

  end

  context 'user_id attribute' do
    it 'cannot be mass assigned'

    it 'cannot be null'

    it 'belongs to one user'
  end
end
