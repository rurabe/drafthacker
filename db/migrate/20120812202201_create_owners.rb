class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.boolean :commissioner
      t.string :name
      t.string :cbs_hex_id
      t.references :team

      t.timestamps
    end
  end
end
