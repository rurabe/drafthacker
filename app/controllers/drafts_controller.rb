class DraftsController < ApplicationController

  def show

      @access = params['access_token']
      @mega_hash = Cbs::League.build_mega_hash( { :access_token => @access, :cbs_id => params['user_id'] } 

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

    @players_drafted = players_ids(@user)# For Players Partial

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

  def players_ids(user)
    players_drafted = []
    user.drafts.first.drafted_players.each do |p|
      players_drafted << p.id
    end
    players_drafted
  end

end
