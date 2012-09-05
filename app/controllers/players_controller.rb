class PlayersController < ApplicationController
	layout false

  def show
  	@player = Player.find(params[:id])
  	@team = Team.find_by_id(params[:team])
  	@chances = @player.chance(@team)
  end
end
