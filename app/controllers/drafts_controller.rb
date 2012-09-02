class DraftsController < ApplicationController

  def show

    if params['access_token'] == "" || params['access_token'] != true
      # params is a development set of params with symbolized_keys! # Updated 8/31/2012
      params = {"access_token"=>"U2FsdGVkX19BZczZgzxwaKawHs15NSSb9bbJKqElEwMTh1CrTcqVjFDhmGaZkpv7GUfzPjMhP6DkFPRgAzko16iKOpk4KlDQb12EgfuDBzHGRvvMePudLxMnMJtJ2E8O", "user_id"=>"b2c7c77e1b22e0f4", "SPORT"=>"football", "league_id"=>"3531-h2h", "controller"=>"drafts", "action"=>"show"}.symbolize_keys!
      access = params[:access_token]
      cbs_id = params[:user_id]
      league_name = params[:league_id]
    else
      access = params['access_token']
      cbs_id = params['user_id']
    end
    
    # @picks = Pick.all(:number)
    
    UpdatesAndInserts::UsersAndDrafts.upsert_all( :access_token => access, :cbs_id => cbs_id )
    @user = User.find_by_cbs_id(cbs_id)
    @draft = @user.drafts.first
    @league = @draft.league
    @team = @user.team
    @slot = @team.slots.first
    @round = @draft.rounds.first
    @pick = @round.picks.first
    @players = @draft.undrafted_players
    @url = draft_url(@draft)
    @user_id = @user.cbs_id
    
    # Cbs::Draft.update(:access_token => @access, :draft => @user.drafts.first)
  end

  def update
    
    if params['access_token'] == "" || params['access_token'] != true
      # params is a development set of params with symbolized_keys! # Updated 8/31/2012
      params = {"access_token"=>"U2FsdGVkX19BZczZgzxwaKawHs15NSSb9bbJKqElEwMTh1CrTcqVjFDhmGaZkpv7GUfzPjMhP6DkFPRgAzko16iKOpk4KlDQb12EgfuDBzHGRvvMePudLxMnMJtJ2E8O", "user_id"=>"b2c7c77e1b22e0f4", "SPORT"=>"football", "league_id"=>"3531-h2h", "controller"=>"drafts", "action"=>"show"}.symbolize_keys!
      access = params[:access_token]
      cbs_id = params[:user_id]
      league_name = params[:league_id]
    else
      access = params['access_token']
      cbs_id = params['user_id']
    end
    
    @user = User.find_by_cbs_id(cbs_id)
    
    UpdatesAndInserts::UsersAndDrafts.upsert_all( :access_token => access, :cbs_id => cbs_id )
    # Cbs::Draft.update(:access_token => access, :draft => @user.drafts.first)
    
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
