class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.references :draft

      t.timestamps
    end
    add_index :rounds, :draft_id
  end
end
