class CreateSales < ActiveRecord::Migration[5.0]
  def change
    create_table :sales do |t|
      t.date	:date
      t.string  :buyer
      t.integer :project_id
      t.integer :unit_id
      t.integer  :status, default: 0
      t.string  :package
      t.string  :remark
      t.date	:spa_sign_date
      t.date 	:la_date
      t.timestamps
    end
    add_index :sales, :project_id
    add_index :sales, :unit_id
    add_index :sales, :date
  end
end
