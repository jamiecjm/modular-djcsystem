class RenameTable < ActiveRecord::Migration[5.1]
  def up
  	rename_table :position_commissions, :positions_commissions unless table_exists?(:positions_commissions)
  end
  def down
  	rename_table :positions_commissions, :position_commissions
  end
end
