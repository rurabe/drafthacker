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
  end

  def index
  end

end
