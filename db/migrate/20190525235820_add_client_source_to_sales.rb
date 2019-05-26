class AddClientSourceToSales < ActiveRecord::Migration[5.1]
  def change
    add_column :sales, :buyer_source, :string
  end
end
