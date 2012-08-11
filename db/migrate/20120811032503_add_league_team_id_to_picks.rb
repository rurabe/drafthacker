class AddLeagueTeamIdToPicks < ActiveRecord::Migration
  def change
    add_column :picks, :league_team_id, :integer
    remove_column :picks, :team_info
  end
end
