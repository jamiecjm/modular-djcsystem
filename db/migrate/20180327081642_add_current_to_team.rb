class AddCurrentToTeam < ActiveRecord::Migration[5.1]
  def up
    return if column_exists?(:teams, :current)
    add_column :teams, :current, :boolean, default: true
  end

  def down
    remove_column :teams, :current
  end
end
