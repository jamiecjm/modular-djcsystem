class RemoveOverridingPercentage < ActiveRecord::Migration[5.1]
  def up
    return if !column_exists?(:positions, :overriding_percentage)
    remove_column :positions, :overriding_percentage
  end

  def down
    add_column :positions, :overriding_percentage, :float
  end
end
