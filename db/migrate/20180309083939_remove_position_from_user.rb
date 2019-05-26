class RemovePositionFromUser < ActiveRecord::Migration[5.1]
  def up
    return if !column_exists?(:users, :position)
    remove_column :users, :position
  end

  def down
    add_column :users, :position, :integer
  end
end
