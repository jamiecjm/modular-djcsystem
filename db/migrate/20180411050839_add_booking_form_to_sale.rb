class AddBookingFormToSale < ActiveRecord::Migration[5.1]
  def up
    return if column_exists?(:sales, :booking_form)
    add_column :sales, :booking_form, :string
  end

  def down
    remove_column :sales, :booking_form
  end
end
