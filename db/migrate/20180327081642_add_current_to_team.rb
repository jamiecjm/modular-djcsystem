class AddCurrentToTeam < ActiveRecord::Migration[5.1]
  def up
    add_column :teams, :current, :boolean, default: true
  end

  def down
  	remove_column :teams, :current
  end
end
