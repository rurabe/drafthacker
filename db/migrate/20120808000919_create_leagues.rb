class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.string :name
      t.references :draft

      t.timestamps
    end
    add_index :leagues, :draft_id
  end
end
