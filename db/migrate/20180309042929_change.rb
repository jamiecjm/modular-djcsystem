class Change < ActiveRecord::Migration[5.1]
  def up
	
  	add_column :sales, :status_string, :string
  	Sale.all.each do |s|
  		s.status_string = s.status
  		s.save
  	end
  	add_column :users, :location_string, :string
  	User.all.each do |u|
  		u.location_string = u.location
  		u.save
  	end
  end

  def down
  	remove_column :sales, :status_string
  	remove_column :users, :location_string
  end
end
