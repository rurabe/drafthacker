class ChangePrimaryPostionToPlayer < ActiveRecord::Migration

  def change
  	 rename_column :players, :primary_position, :position
  end

end
