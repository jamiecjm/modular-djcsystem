class RemoveOverridingPercentage < ActiveRecord::Migration[5.1]
  def up
  	remove_column :positions, :overriding_percentage
  end

  def down
  	add_column :positions, :overriding_percentage, :float
  end
end
