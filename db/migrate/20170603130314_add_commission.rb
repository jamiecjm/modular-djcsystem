class AddCommission < ActiveRecord::Migration[5.0]
  def change
  	add_column :sales, :commission_id, :integer
  	add_index :sales, :commission_id
  end
end
