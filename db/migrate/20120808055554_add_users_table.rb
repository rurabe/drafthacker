class AddUsersTable < ActiveRecord::Migration
	def change
		create_table :users do |t|
			t.string :cbs_id

			t.timestamps
		end
	end
end
