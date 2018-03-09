class RemovePositionFromUser < ActiveRecord::Migration[5.1]
  def up
  	remove_column :users, :position
  end

  def down
  	add_column :users, :position, :integer
  end
end
