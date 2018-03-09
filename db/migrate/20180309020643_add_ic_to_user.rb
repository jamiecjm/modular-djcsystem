class AddIcToUser < ActiveRecord::Migration[5.1]
  def up
  	add_column :users, :ic_no, :integer
  end

  def down
  	remove_column :users, :ic_no
  end
end
