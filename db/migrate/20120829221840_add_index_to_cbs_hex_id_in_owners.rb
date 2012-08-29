class AddIndexToCbsHexIdInOwners < ActiveRecord::Migration
  def change
    add_index :owners, :cbs_hex_id
  end
end
