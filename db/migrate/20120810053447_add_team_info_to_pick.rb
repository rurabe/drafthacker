class AddTeamInfoToPick < ActiveRecord::Migration
  def change
    add_column :picks, :number, :integer
    add_column :picks, :team_info, :string
  end
end
