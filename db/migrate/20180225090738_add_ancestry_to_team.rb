class AddAncestryToTeam < ActiveRecord::Migration[5.1]
  def up
  	add_column :teams, :overriding, :boolean, default: false, if: column_exists?(:teams, :overriding)
  	add_column :teams, :overriding_percentage, :float, if: column_exists?(:teams, :overriding_percentage)
    team = Team.search(id_in: User.pluck(:team_id)).result
  	team.update_all(overriding: true)
    users = team.pluck(:leader_id)
    User.where.not(id: users).each do |u|
    	t = Team.new(leader_id: u.id)
      t.save(validation: false)
    end
    User.all.each do |u|
    	t = u.team
    	t.update(parent_id: u.parent&.team&.id)
    end

  end

  def down
  	# remove_column :teams, :overriding
  	# remove_column :teams, :overriding_percentage
   #  users = Team.pluck(:user_id)
   #  User.where.not(id: users).each do |u|
   #  	t = Team.find_by(user_id: u.id)
   #  	t.destroy
   #  end
  end
end
