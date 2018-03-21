class RemoveUnusedColumn < ActiveRecord::Migration[5.1]
  def up
  	remove_column :teams, :overriding if column_exists?(:teams, :overriding)
  	remove_column :teams, :overriding_percentage if column_exists?(:teams, :overriding_percentage)
  	remove_column :sales, :unit_id if column_exists?(:sales, :unit_id)
  	remove_column :commissions, :position_id if column_exists?(:commissions, :position_id)
  	drop_table :units if table_exists?(:units)
  end

  def down
  	add_column :teams, :overriding, :boolean
  	add_column :overriding_percentage, :float
  	add_column :sales, :unit_id, :integer
  	add_column :commissions, :position_id, :integer
  end
end
