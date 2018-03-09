class ChangeStatusName < ActiveRecord::Migration[5.1]
  def up
  	remove_column :sales, :status
  	rename_column :sales, :status_string, :status
  	remove_column :users, :location
  	rename_column :users, :location_string, :location
  	change_column :users, :position, :string
  end

  def down
  	rename_column :sales, :status, :status_string
  	add_column :sales, :status
  	rename_column :users, :location, :location_string
  	add_column :users, :location
  	change_column :users, :position, :integer
  end
end
