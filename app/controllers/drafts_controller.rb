class DraftsController < ApplicationController

  def show

    if params['access_token']
      @mega_hash = Cbs::League.build_mega_hash( { :access_token => params['access_token'], :cbs_id => params['user_id'] } )
    else
      @mega_hash = Cbs::League.build_mega_hash( { :access_token => 'U2FsdGVkX1_sDdfdJ7MDfQ2OYvQ6nlPPqpkkIEVu8jo0DNyGS8l3KPjJGY37Efhh3HXyJv0BMWCwTmBpBPRGrZUKIZVP5RGoqw_NSXD4DQiurGk2XFmQ', :cbs_id => 'b2c7c77e1b22e0f4' } )
    end

    @status = Cbs::Draft.status(:access_token => 'U2FsdGVkX1_sDdfdJ7MDfQ2OYvQ6nlPPqpkkIEVu8jo0DNyGS8l3KPjJGY37Efhh3HXyJv0BMWCwTmBpBPRGrZUKIZVP5RGoqw_NSXD4DQiurGk2XFmQ')
    @access = params[:access_token]
    # @picks = Pick.all(:number)
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
