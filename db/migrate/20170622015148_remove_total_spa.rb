class RemoveTotalSpa < ActiveRecord::Migration[5.0]
  def change
  	remove_column :users, :total_spa
  	remove_column :users, :total_nett_value
  	remove_column :users, :total_comm
  	remove_column :users, :total_sales
  end
end