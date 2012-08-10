class DraftsController < ApplicationController

  def show
    if params['access_token']
      @mega_hash = Cbs::League.params(params['access_token'], params['user_id'])
    else
      @mega_hash = Cbs::League.params('U2FsdGVkX1-r3rVlygny0MK8WI1QW9Kb9IZRO0tiz3YBzDltmdjVumhYsQ_mue54lQSG31A45CPBQfof1Xz6aRAmhsPH4CBaAmyuPS7wPdwwhfD78_xQYxL0E07-L8Ih', 'b2c7c77e1b22e0f4')
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
