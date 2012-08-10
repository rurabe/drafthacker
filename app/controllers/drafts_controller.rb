class DraftsController < ApplicationController

  def show
    @user = User.new(Cbs::League.params(params['access_token'], params['user_id']))
    @user.save
    audit "SHIIT"
  end

  def index
  end

end
