class AddRoundNumberToPicks < ActiveRecord::Migration
  def change
    add_column :picks, :round_number, :integer
  end
end
