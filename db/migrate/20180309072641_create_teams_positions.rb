class CreateTeamsPositions < ActiveRecord::Migration[5.1]
  def up
  	if !table_exists?(:teams_positions)
	    create_table :teams_positions do |t|
	    	t.integer :team_id
	    	t.integer :position_id
	    	t.date	:effective_date
	      t.timestamps
	    end
	end

    add_index :teams_positions, :team_id
    add_index :teams_positions, :position_id
    add_index :teams_positions, [:team_id, :position_id], unique: true

    Team.all.each do |t|
    	if t.overriding
    		TeamsPosition.create(team_id: t.id, position_id: 1, effective_date: '2000-1-1'.to_date)
    	else
    		TeamsPosition.create(team_id: t.id, position_id: 2, effective_date: '2000-1-1'.to_date)
    	end
    end

  end

  def down
  	drop_table :teams_positions
  end
end
