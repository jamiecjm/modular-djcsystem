class AddPositionIdToCommission < ActiveRecord::Migration[5.1]
  def up
  	add_column :commissions, :position_id, :integer
  	add_index :commissions, :position_id
  end

  def down
  	remove_column :commissions, :position_id
  end
end
