class AddOwnerHexIdToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :owner_hex_id, :string
    add_index :teams, :owner_hex_id 
  end
end
