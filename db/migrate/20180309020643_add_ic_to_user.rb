class AddIcToUser < ActiveRecord::Migration[5.1]
  def up
    return if column_exists?(:users, :ic_no)
    add_column :users, :ic_no, :integer
  end

  def down
    remove_column :users, :ic_no
  end
end
