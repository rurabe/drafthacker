class DraftsController < ApplicationController
	include CbsClient

  def show
  	@params = get_params#(params["access_token"], params["user_id"])
  end

  def index
  	Faker::Lorem.words
  end

end
