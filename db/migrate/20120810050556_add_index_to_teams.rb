class AddIndexToTeams < ActiveRecord::Migration
  def change
    change_table :teams do |t|
		  t.index :league_id
		  t.index :league_team_id
		end
  end
end
