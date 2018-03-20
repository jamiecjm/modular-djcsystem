class AddHiddenToTeams < ActiveRecord::Migration[5.1]
  def up
  	add_column :teams, :hidden, :boolean, default: false
  end

  def down
  	remove_column :teams, :hidden
  end
end
