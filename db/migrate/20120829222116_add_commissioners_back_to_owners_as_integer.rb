class AddCommissionersBackToOwnersAsInteger < ActiveRecord::Migration
  def change
    add_column :owners, :commissioner, :integer
  end
end
