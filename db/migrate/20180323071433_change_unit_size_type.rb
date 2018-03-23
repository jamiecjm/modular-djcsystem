class ChangeUnitSizeType < ActiveRecord::Migration[5.1]
  def up
  	change_column :sales, :unit_size, :integer
  end

  def down
  	change_column :sales, :unit_size, :float
  end
end
