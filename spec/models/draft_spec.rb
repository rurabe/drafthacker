require 'spec_helper'

describe Draft do
  it { should belong_to :user }
  it { should have_one :league }
  it { should validate_presence_of :user_id }

end
