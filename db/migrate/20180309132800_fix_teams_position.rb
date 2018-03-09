class FixTeamsPosition < ActiveRecord::Migration[5.1]
  def up
  	all_team = TeamsPosition.pluck(:team_id)
  	Team.where.not(id: all_team).each do |t|
  		t.create_team_position
  	end
  end

  def down
  end
end
