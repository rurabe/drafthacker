class RemoveTeamIdFromPlayers < ActiveRecord::Migration
  def up
    remove_column :players, :team_id
  end

  def down
    add_column :players, :team, :references
  end
end
