class RemoveIconsHeadlineAndIconsInjuryFromPlayers < ActiveRecord::Migration
  def up
    remove_column :players, :icons_headline
    remove_column :players, :icons_injury
  end

  def down
    add_column :players, :icons_headline, :string
    add_column :players, :icons_injury, :string
  end
end
