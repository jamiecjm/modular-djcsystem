class AddReferrerId < ActiveRecord::Migration[5.1]
  def up
  	add_column :users, :referrer_id, :integer unless column_exists?(:users, :referrer_id)
  	add_column :teams, :upline_id, :integer unless column_exists?(:teams, :upline_id)
  	add_index :users, :referrer_id unless index_exists?(:users, :referrer_id)
  	add_index :teams, :upline_id unless index_exists?(:teams, :upline_id)
  	User.all.each do |u|
  		u.update(referrer_id: u.ancestry&.split('/')&.last)
  	end
  	Team.all.each do |t|
  		t.update(upline_id: t.ancestry&.split('/')&.last)
  	end
  end
  def down
  	add_column :users, :referrer_id
  	add_column :teams, :upline_id
  end
end
