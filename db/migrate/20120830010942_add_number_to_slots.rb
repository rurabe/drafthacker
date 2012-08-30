class AddNumberToSlots < ActiveRecord::Migration
  def change
    add_column :slots, :number, :integer
  end
end
