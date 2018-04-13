class AddBookingFormToSale < ActiveRecord::Migration[5.1]
  def up
    add_column :sales, :booking_form, :string
  end

  def down
  	remove_column :sales, :booking_form
  end
end
