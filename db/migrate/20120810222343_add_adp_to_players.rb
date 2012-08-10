class AddAdpToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :high, :integer
    add_column :players, :low, :integer
    add_column :players, :profile_link, :string
    add_column :players, :pct, :integer
    add_column :players, :change, :integer
    add_column :players, :avg, :integer
    add_column :players, :profile_url, :string
    add_column :players, :rank, :integer
  end
end
