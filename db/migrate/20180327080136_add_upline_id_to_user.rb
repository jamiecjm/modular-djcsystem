class AddUplineIdToUser < ActiveRecord::Migration[5.1]
  def up
  	add_column :users, :upline_id, :integer unless column_exists?(:users, :upline_id)
  	add_index :users, :upline_id unless index_exists?(:users, :upline_id)
  	User.find_each do |u|
  		u.update_column(:upline_id, u.current_team.upline_id)
  	end
  end

  def down
  	remove_column :users, :upline_id
  end
end
