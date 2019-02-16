class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string    :name
      t.integer   :leader_id
      t.string    :ancestry
      t.timestamps
    end

    add_index :teams, :leader_id
    add_index :teams, :ancestry
  end
end
