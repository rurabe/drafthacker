class DraftsController < ApplicationController

  def show
    if params['access_token']
      @mega_hash = Cbs::League.params(params['access_token'], params['user_id'])
    else
      @mega_hash = Cbs::League.params()
    end
    @user = User.new(@mega_hash)
    @user.save
    @draft = @user.drafts.first
    @league = @draft.league
    @team = @league.teams.first
    @slot = @team.slots.first
  end

  def index
  end

end
