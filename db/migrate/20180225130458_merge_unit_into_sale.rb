class MergeUnitIntoSale < ActiveRecord::Migration[5.1]
  def up
  	add_column :sales, :unit_no, :string
  	add_column :sales, :unit_size, :float
  	add_column :sales, :spa_value, :float
  	add_column :sales, :nett_value, :float

  	Unit.all.each do |u|
  		sale = u.sale
  		sale.update(unit_no: u.unit_no, unit_size: u.size, spa_value: u.spa_price, nett_value: u.nett_price)
  	end
  end

  def down
  	remove_column :sales, :unit_no
  	remove_column :sales, :size
  	remove_column :sales, :spa_value
  	remove_column :sales, :nett_value
  end
end
