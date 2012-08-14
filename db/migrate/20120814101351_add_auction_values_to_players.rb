class AddAuctionValuesToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :av_cbs, :integer
    add_column :players, :av_cbs_ppr, :integer
    add_column :players, :av_dave_richard, :integer
    add_column :players, :av_dave_richard_ppr, :integer
    add_column :players, :av_jamey_eisenberg, :integer
    add_column :players, :av_jamey_eisenberg_ppr, :integer
    add_column :players, :av_nathan_zegura, :integer
  end
end
