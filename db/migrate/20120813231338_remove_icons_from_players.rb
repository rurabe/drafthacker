class RemoveIconsFromPlayers < ActiveRecord::Migration
  def change
  	remove_column :players, :icons 
  end
end
