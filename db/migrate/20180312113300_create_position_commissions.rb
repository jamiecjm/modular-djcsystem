class CreatePositionCommissions < ActiveRecord::Migration[5.1]
  def up
    drop_table :position_commissions if table_exists?(:position_commissions)

    create_table :position_commissions do |t|
    	t.integer	:position_id
    	t.integer	:commission_id
    	t.float	:percentage
      t.timestamps
    end
    

    add_index :position_commissions, :position_id unless index_exists?(:position_commissions, :position_id)
    add_index :position_commissions, :commission_id unless index_exists?(:position_commissions, :commission_id)
    add_index :position_commissions, [:position_id, :commission_id], unique: true unless index_exists?(:position_commissions, [:position_id, :commission_id])
  end

  def down
  	drop_table :position_commissions
  end
end
