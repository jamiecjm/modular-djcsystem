class CreateOverridings < ActiveRecord::Migration[5.1]
  def up
  	unless table_exists?(:overridings)
	    create_table :overridings do |t|
	    	t.integer :team_id
	    	t.integer	:salevalue_id
	    	t.float	:override
	      t.timestamps
	    end
	end

    add_index :overridings, :team_id unless index_exists?(:overridings, :team_id)
    add_index :overridings, :salevalue_id unless index_exists?(:overridings, :salevalue_id)
    add_index :overridings, [:team_id, :salevalue_id], unique: true
  end

  def down
  	drop_table :overridings
  end
end
