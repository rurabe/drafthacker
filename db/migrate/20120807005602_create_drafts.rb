class CreateDrafts < ActiveRecord::Migration
  def change
    create_table :drafts do |t|
      t.references :user
      t.string :name
      t.datetime :start_time

      t.timestamps
    end
    add_index :drafts, :user_id
  end
end
