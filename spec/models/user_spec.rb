require 'spec_helper'

describe User do
  it { should have_many :drafts }
  it { should have_one :team }
  it { should accept_nested_attributes }

end
