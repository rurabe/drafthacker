class DraftsController < ApplicationController
  include CbsClient

  def show
    @params = get_params('U2FsdGVkX1-r3rVlygny0MK8WI1QW9Kb9IZRO0tiz3YBzDltmdjVumhYsQ_mue54lQSG31A45CPBQfof1Xz6aRAmhsPH4CBaAmyuPS7wPdwwhfD78_xQYxL0E07-L8Ih', 'b2c7c77e1b22e0f4')
  end

  def index
    Faker::Lorem.words
  end

end
