class DraftsController < ApplicationController

  def show
    @params = Cbs::League.params(params['access_token'], params['user_id'])
  end

  def index
    Faker::Lorem.words
  end

end
