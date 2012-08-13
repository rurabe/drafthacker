class ChangeLogoInTeamsToText < ActiveRecord::Migration
  def change
  	remove_column :teams, :logo
  	add_column :teams, :logo, :text
  end
end
