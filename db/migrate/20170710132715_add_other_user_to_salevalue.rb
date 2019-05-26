class AddOtherUserToSalevalue < ActiveRecord::Migration[5.1]
  def up
    return if column_exists?(:salevalues, :other_user)
    add_column :salevalues, :other_user, :string, unless: column_exists?(:salevalues, :other_user)
    add_column :sales, :unit_no, :string, unless: column_exists?(:sales, :unit_no)
    add_column :sales, :unit_size, :float, unless: column_exists?(:sales, :unit_size)
    add_column :sales, :spa_value, :float, unless: column_exists?(:sales, :spa_value)
    add_column :sales, :nett_value, :float, unless: column_exists?(:sales, :nett_value)

    User.where(team_id: nil).each do |u|
      u.salevalues.each do |sv|
        sv.update_columns(user_id: nil, other_user: u.prefered_name)
      end
    end
    # Unit.all.each do |u|
    #   sale = u.sale
    #   sale.update_columns(unit_no: u.unit_no, unit_size: u.size, spa_value: u.spa_price, nett_value: u.nett_price)
    # end
  end

  def down
    remove_column :salevalues, :other_user
    remove_column :sales, :unit_no
    remove_column :sales, :size
    remove_column :sales, :spa_value
    remove_column :sales, :nett_value
  end
end
