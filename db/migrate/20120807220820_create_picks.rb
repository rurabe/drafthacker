class CreatePicks < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.references :player
      t.references :team
      t.references :round

      t.timestamps
    end
    add_index :picks, :player_id
    add_index :picks, :team_id
    add_index :picks, :round_id
  end
end
