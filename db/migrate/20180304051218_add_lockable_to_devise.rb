class AddLockableToDevise < ActiveRecord::Migration[5.1]
  def up
  	add_column :users, :locked_at, :datetime
  	User.where(approved?: false).each do |u|
  		u.update_column(:locked_at, u.created_at)
  	end
  	remove_column :users, :approved?
  end

  def down
  	add_column :users, :approved?, :boolean, default: false
  	remove_column :users, :locked_at
  end
end
