require 'spec_helper'

describe Pick do
  it { should belong_to :round}
  it { should belong_to :player}
  it { should belong_to :team}

end
