class AddStuffToPlayer < ActiveRecord::Migration
  def change
  	add_column :players, :pct    , :decimal
		add_column :players, :change , :decimal
		add_column :players, :avg    , :decimal
    add_column :players, :high	 , :integer
    add_column :players, :low		 , :integer
    add_column :players, :rank   , :integer
  end
end
