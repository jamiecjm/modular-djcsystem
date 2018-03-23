class AddHiddenToTeams < ActiveRecord::Migration[5.1]
  def up
  	add_column :teams, :hidden, :boolean, default: true unless column_exists?(:teams, :hidden)
  end

  def down
  	remove_column :teams, :hidden
  end
end
