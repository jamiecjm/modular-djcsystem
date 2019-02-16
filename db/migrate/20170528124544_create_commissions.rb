class CreateCommissions < ActiveRecord::Migration[5.0]
  def change
    create_table :commissions do |t|
    	t.integer	:project_id
    	t.float		:percentage
    	t.date		:effective_date
      t.timestamps
    end
    add_index :commissions, [:id,:project_id]
  end

end
