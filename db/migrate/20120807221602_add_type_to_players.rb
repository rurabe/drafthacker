class AddTypeToPlayers < ActiveRecord::Migration
  def change
    add_column  :players, :type, :string
  end
end
