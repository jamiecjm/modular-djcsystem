class RenameTeam < ActiveRecord::Migration[5.1]
  def up
  	add_column :teams, :position_id, :integer if !column_exists?(:teams, :position_id)
  	add_column :teams, :effective_date, :date if !column_exists?(:teams, :effective_date)
  	TeamsPosition.all.each do |tp|
  		tp&.team&.update_columns(position_id: tp.position_id, effective_date: tp.effective_date)
	  end
  end

  def down
  	remove_column :teams, :position_id
  	remove_column :teams, :effective_date

  end
end
