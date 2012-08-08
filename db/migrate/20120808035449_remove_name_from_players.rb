class RemoveNameFromPlayers < ActiveRecord::Migration
  def up
    remove_column :players, :name
  end

  def down
    add_column :players, :name, :string
  end
end
