class CreatePositions < ActiveRecord::Migration[5.1]
  def up
    return if table_exists?(:positions)
    create_table :positions do |t|
    	t.string :title, unique: true
    	t.boolean :overriding, default: false
    	t.float	:overriding_percentage
    	t.string :ancestry
    	t.boolean :default
      t.timestamps
    end
    add_index :positions, :ancestry
    Position.create(title: 'Team Leader', overriding: true)
    Position.create(title: 'REN', default: true, parent_id: 1)
    # remove_column :teams, :overriding
    # remove_column :teams, :overriding_percentage
  end

  def down
  	drop_table :positions
  	# add_column :teams, :overriding, :boolean
   #  add_column :teams, :overriding_percentage, :float
  end
end
