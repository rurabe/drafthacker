class AddIndexCbsIdToUsers < ActiveRecord::Migration
  def change
    add_index   :users, :cbs_id
  end
end
