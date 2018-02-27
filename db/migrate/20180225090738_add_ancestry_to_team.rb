class AddAncestryToTeam < ActiveRecord::Migration[5.1]
  def up
  	add_column :teams, :overriding, :boolean, default: false
  	add_column :teams, :overriding_percentage, :float
  	Team.update_all(overriding: true)
    leaders = Team.pluck(:leader_id)
    User.where.not(id: leaders).each do |u|
    	t = Team.create(leader_id: u.id)
    end
    User.all.each do |u|
    	t = u.pseudo_team
    	t.update(parent_id: u.parent&.pseudo_team&.id)
    end

  end

  def down
  	# remove_column :teams, :overriding
  	# remove_column :teams, :overriding_percentage
   #  leaders = Team.pluck(:leader_id)
   #  User.where.not(id: leaders).each do |u|
   #  	t = Team.find_by(leader_id: u.id)
   #  	t.destroy
   #  end
  end
end
