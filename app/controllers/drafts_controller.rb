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
    @user_id = @user.cbs_id
    Cbs::Draft.update(:access_token => @access, :draft_id => @user.drafts.first)
  end

  def update
    @user = User.find(params[:user_id])

    Cbs::Draft.update(:access_token => params[:access_token], :draft_id => @user.drafts.first)
    # For Players Partial
    @team = @user.team
    @players_drafted = players(@user)

    @feed = @user.drafts.first.build_feed
    

    # For Feed
    respond_to do |format|
      format.js
    end

  end

  def players(user)
    players_drafted = []
    user.drafts.first.drafted_players.each do |p|
      players_drafted << p
    end
    players_drafted
  end
end
