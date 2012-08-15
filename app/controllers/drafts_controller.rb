class DraftsController < ApplicationController

  def show

    if params['access_token']
      @access = params['access_token']
      @mega_hash = Cbs::League.build_mega_hash( { :access_token => @access, :cbs_id => params['user_id'] } )
    else
      @access = 'U2FsdGVkX1-PJB-AOD6mt4-EtlEufOn4YqtVtDngv-ZdT_JrpxBP3dw66PO_iCbknecw63_XXMEkBC2zVRmPQhUTgfk0KvQ_nDMahgM96JC6rdqMqGzb4P8vttFOzSBz'
      @mega_hash = Cbs::League.build_mega_hash( { :access_token => @access, :cbs_id => 'b2c7c77e1b22e0f4' } )
    end

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
    @players = Player.where(:position => ['WR', 'QB', 'RB', 'K'])
    @url = draft_url(@draft)
  end

  def update
    # Cbs::Draft.update(:access_token => params[:access_token], :draft_id => @user.draft.first.id)
    # Cbs::Players.update
    @user = User.find_by_cbs_id(params[:user_id])
    Cbs::Draft.update(:access_token => params[:access_token], :draft_id => @user.drafts.first.id)
    # Cbs::Players.update
    # For Players Partial
    @players = Player.where(:position => ['WR', 'QB', 'RB', 'K'])
    # @players.order_by([:avg, :desc])
    @team = @user.team
    @feed = { 'feed' => "This is a feed item"}.to_json.html_safe #Cbs::Feed

    respond_to do |format|
      format.js
    end

  end

end
