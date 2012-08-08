class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.references :team
      t.references :player
      t.string :eligible_positions

      t.timestamps
    end
    add_index :slots, :team_id
    add_index :slots, :player_id
  end
end
