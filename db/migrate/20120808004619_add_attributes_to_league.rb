class AddAttributesToLeague < ActiveRecord::Migration
  def change

  	remove_column :leagues, :name

 	# League Details - http://api.cbssports.com/fantasy/league/details
  	add_column :leagues, :regular_season_periods, :integer
  	add_column :leagues, :playoff_periods, :integer
  	add_column :leagues, :season_status, :string
  	add_column :leagues, :name, :string
  	add_column :leagues, :draft_type, :string
  	add_column :leagues, :num_divisions, :integer
  	add_column :leagues, :uses_keepers, :integer
  	add_column :leagues, :num_teams, :integer
  		# this attribute is actually called type when it comes in from the API, but type is a reserved word
  	add_column :leagues, :commish_type, :string

  # Draft Config - http://api.cbssports.com/fantasy/league/draft/config
  	add_column :leagues, :use_robot, :boolean
  	add_column :leagues, :time, :time
  	add_column :leagues, :date, :date
  	add_column :leagues, :order_type, :string
  	add_column :leagues, :order_source, :string
  	add_column :leagues, :auction_supplemental_rounds, :integer
  	add_column :leagues, :timer_start, :integer
  	add_column :leagues, :pick_email, :boolean
  		#this attribute is also called type
  	add_column :leagues, :draft_event_type, :string
  	add_column :leagues, :draft_schedule, :string
  	add_column :leagues, :rounds, :integer
  	add_column :leagues, :time_limit, :integer
  	add_column :leagues, :timer_end, :integer
  end
end
