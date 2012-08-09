class DeleteDraftAttributes < ActiveRecord::Migration
  def up
  	remove_column :drafts, :name
  	remove_column :drafts, :start_time
  end

  def down
  	add_column :drafts, :name, :string
  	add_column :drafts, :start_time, :datetime
  end
end
