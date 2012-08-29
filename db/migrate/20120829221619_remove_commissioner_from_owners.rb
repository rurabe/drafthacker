class RemoveCommissionerFromOwners < ActiveRecord::Migration
  def up
    remove_column :owners, :commissioner
  end

  def down
    add_column :owners, :commissioner, :boolean
  end
end
