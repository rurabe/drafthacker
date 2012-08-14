class AddDraftIdToPick < ActiveRecord::Migration
  def change
  	change_table :picks do |t|
    	t.references :draft
    end
  end
end
