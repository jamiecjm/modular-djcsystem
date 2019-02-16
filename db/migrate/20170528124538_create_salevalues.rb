class CreateSalevalues < ActiveRecord::Migration[5.0]
  def change
    create_table :salevalues do |t|
    	t.float    	:percentage, :scale => 2
    	t.float    	:nett_value, :scale => 2
    	t.float    	:spa, :scale => 2
    	t.float    	:comm, :scale => 2
    	t.integer	:user_id
    	t.integer	:sale_id
      t.timestamps
    end
    add_index :salevalues, :user_id
    add_index :salevalues, :sale_id
  end
end
