require 'spec_helper'

describe User do
  it { should have_many :drafts }
  it { should have_one :team }
end
