class AddEffectiveDateToTeam < ActiveRecord::Migration[5.1]
  def up
  	add_column :teams, :effective_date, :date
  end

  def down
  	remove_column :teams, :effective_date 
  end
end
