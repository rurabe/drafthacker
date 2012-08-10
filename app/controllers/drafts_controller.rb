class DraftsController < ApplicationController

  def show
    @user = User.new(Cbs::League.params(params['access_token'], params['user_id']))
    @user.save
    @draft = @user.drafts.first
    @league = @draft.league
    @team = @user.team
  end

  def index
  end

end
