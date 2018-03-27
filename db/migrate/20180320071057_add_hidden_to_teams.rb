class AddHiddenToTeams < ActiveRecord::Migration[5.1]
  def up
  	add_column :teams, :hidden, :boolean, default: false unless column_exists?(:teams, :hidden)
  end

  def down
  	remove_column :teams, :hidden
  end
end
