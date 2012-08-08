class AddSlotIdToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :slot_id, :integer
    add_index   :players, :slot_id
  end
end
