class AddIconsInjuryToPlayers < ActiveRecord::Migration
  def change
  	add_column :players, :icons_injury, :string
  	add_column :players, :icons_headline, :string
  end
end
