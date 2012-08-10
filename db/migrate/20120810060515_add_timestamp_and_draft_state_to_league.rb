class AddTimestampAndDraftStateToLeague < ActiveRecord::Migration
  def change
  	add_column :leagues, :draft_state, :string
  	add_column :leagues, :timestamp, :integer
  end
end
