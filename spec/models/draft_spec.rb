require 'spec_helper'

describe Draft do
  it { should belong_to :user }
  it { have_one :league }
end
