class AddShaToDrafts < ActiveRecord::Migration
  def change
    add_column :drafts, :last_response_sha, :string
    add_column :drafts, :last_pick, :integer
  end
end
