class PlayersController < ApplicationController
	layout false

  def show
  	@player = Player.find(params[:id])
  	@user = User.find_by_id(params[:user])
  	if @user
  		@next_pick = @user.team.next_pick.number
  	end
  end
end
