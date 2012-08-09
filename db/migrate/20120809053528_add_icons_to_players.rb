class AddIconsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :icons, :string
  end
end
