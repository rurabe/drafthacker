class AddStuffToTeams < ActiveRecord::Migration
  def change
  	add_column :teams, :long_abbr, :string
   	add_column :teams, :logged_in_team, :boolean
   	add_column :teams, :short_name, :string
   	add_column :teams, :logo, :string
   	add_column :teams, :abbr, :string
   	add_column :teams, :owners, :string
   	add_column :teams, :league_team_id, :integer
  end
end
