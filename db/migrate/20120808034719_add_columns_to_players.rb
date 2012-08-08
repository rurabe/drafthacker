class AddColumnsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :cbs_id,           :integer
    add_column :players, :first_name,       :string
    add_column :players, :full_name,        :string
    add_column :players, :icons_headline,   :string
    add_column :players, :icons_injury,     :string
    add_column :players, :last_name,        :string
    add_column :players, :on_waivers,       :string
    add_column :players, :primary_position, :string
    add_column :players, :pro_status,       :string
    add_column :players, :pro_team,         :string
    add_column :players, :bye_week,         :string
    add_column :players, :is_locked,        :string
    add_column :players, :opponent,          :string

  end
end
