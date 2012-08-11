class DraftsController < ApplicationController

  def show

    if params['access_token']
      @mega_hash = Cbs::League.params(params['access_token'], params['user_id'])
    else
      @mega_hash = Cbs::League.params('U2FsdGVkX1_dqYNjfcxVhErfEI9MqM7-7hNf7v6d64EzPGAjzKpHFAe8cA3jHI2G_KARduk8IlB7L6WNbPbzlXCz0vpOfb9VebWtJJj2A_mPprAYtwtKY1BeMDB_XcdW', 'b2c7c77e1b22e0f4')
    end

    @user = User.new(@mega_hash)
    @user.save
    @draft = @user.drafts.first
    @league = @draft.league
    @team = @user.team
    @slot = @team.slots.first
  end

  def index
  end

end
