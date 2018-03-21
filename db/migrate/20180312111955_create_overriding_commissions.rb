class CreateOverridingCommissions < ActiveRecord::Migration[5.1]
  def up
  	unless table_exists?(:overriding_commissions)
	    create_table :overriding_commissions do |t|
	    	t.integer :team_id
	    	t.integer	:salevalue_id
	    	t.float	:override
	      t.timestamps
	    end
    end

    add_index :overriding_commissions, :team_id unless index_exists?(:overriding_commissions, :team_id)
    add_index :overriding_commissions, :salevalue_id unless index_exists?(:overriding_commissions, :salevalue_id)
    add_index :overriding_commissions, [:team_id, :salevalue_id], unique: true unless index_exists?(:overriding_commissions, [:team_id, :salevalue_id])
  end

  def down
  	drop_table :overriding_commissions
  end
end
