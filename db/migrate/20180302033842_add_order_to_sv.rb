class AddOrderToSv < ActiveRecord::Migration[5.1]
  def up
  	add_column :salevalues, :order, :integer
  	add_column :users, :archived, :boolean, default: false
  end

  def down
  	remove_column :salevalues, :order, :integer
  	remove_column :users, :archived
  end
end
