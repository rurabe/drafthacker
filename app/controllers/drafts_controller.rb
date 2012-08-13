class DraftsController < ApplicationController

  def show

    if params['access_token']
      @access = params['access_token']
      @mega_hash = Cbs::League.build_mega_hash( { :access_token => @access, :cbs_id => params['user_id'] } )
    else
      @access = 'U2FsdGVkX1_dqYNjfcxVhErfEI9MqM7-7hNf7v6d64EzPGAjzKpHFAe8cA3jHI2G_KARduk8IlB7L6WNbPbzlXCz0vpOfb9VebWtJJj2A_mPprAYtwtKY1BeMDB_XcdW'
      @mega_hash = Cbs::League.build_mega_hash( { :access_token => @access, :cbs_id => 'b2c7c77e1b22e0f4' } )
    end

    @user = User.new(@mega_hash)
    @user.save
    @draft = @user.drafts.first
    @league = @draft.league
    @team = @user.team
    @slot = @team.slots.first
    @round = @draft.rounds.first
    @pick = @round.picks.first
  end

  def index
  end

end
