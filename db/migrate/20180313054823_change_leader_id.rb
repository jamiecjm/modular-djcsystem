class ChangeLeaderId < ActiveRecord::Migration[5.1]
  def up
  	rename_column :teams, :leader_id, :user_id
  end

  def down
  	rename_column :teams, :leader_id, :user_id
  end
end
