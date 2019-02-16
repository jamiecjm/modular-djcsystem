class CreateUnits < ActiveRecord::Migration[5.0]
  def change
    create_table :units do |t|
    	t.string	:unit_no
    	t.integer	:size
    	t.float  	:nett_price, :scale => 2
    	t.float	    :spa_price, :scale => 2
    	t.float    	:comm, :scale => 2
      t.float     :comm_percentage
      t.integer   :project_id
      t.integer   :sale_id
      t.timestamps
    end
    add_index :units, [:id,:project_id]
    add_index :units, [:id,:sale_id]
  end
end
