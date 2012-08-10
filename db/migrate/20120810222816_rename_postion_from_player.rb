class RenamePostionFromPlayer < ActiveRecord::Migration
  def up
    rename_column :players, :primary_position, :position
  end

  def down
    rename_column :players, :position, :primary_position
  end
end
