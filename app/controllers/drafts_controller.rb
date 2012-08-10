class DraftsController < ApplicationController

  def show
  	@mega_hash = Cbs::League.params(params['access_token'], params['user_id'])
    @user = User.new(@mega_hash)
    @user.save
    @draft = @user.drafts.first
  end

  def index
  end

end
