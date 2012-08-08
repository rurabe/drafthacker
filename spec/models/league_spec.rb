require 'spec_helper'

describe League do
  it { should belong_to :draft }
  it { should have_many :teams }
  
end
