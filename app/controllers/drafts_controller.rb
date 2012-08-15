class DraftsController < ApplicationController

  def show

    if params['access_token']
      @access = params['access_token']
      @mega_hash = Cbs::League.build_mega_hash( { :access_token => @access, :cbs_id => params['user_id'] } )
    else
      @access = 'U2FsdGVkX18ymiCGQKbnKF1wRkPuYjQFFlLLm06kT916deFHYTeUG3fit5FtQZdxLF1s3NTIt_thZLfGsFbbSUHmjoHw_V86VExqf_vnbDfcrasSQuuEZaAq9vNRPaDf'
      @mega_hash = Cbs::League.build_mega_hash( { :access_token => @access, :cbs_id => 'b2c7c77e1b22e0f4' } )
    end

    # @access = params[:access_token]
    # @picks = Pick.all(:number)
    @user = User.new(@mega_hash)
    @user.save
    @draft = @user.drafts.first
    @league = @draft.league
    @team = @user.team
    @slot = @team.slots.first
    @round = @draft.rounds.first
    @pick = @round.picks.first
    @players = @draft.undrafted_players
    @url = draft_url(@draft)
  end

  def update
    @user = User.find(params[:user_id])

    Cbs::Draft.update(:access_token => params[:access_token], :draft_id => @user.drafts.first.id)

    # For Players Partial
    @players = @user.drafts.first.undrafted_players
    @team = @user.team
    warn "*"*100
    @team.slots.order(:created_at).each do |s|
      warn s.inspect
    end


    # For Feed
    @feed = @user.drafts.first.build_feed
    respond_to do |format|
      format.js
    end

  end

end
