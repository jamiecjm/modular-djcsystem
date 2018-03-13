class MigratePercentageToNewTable < ActiveRecord::Migration[5.1]
  def up
  	default_id = Position.find_by(default: true).id
  	ids = Position.where.not(id: default_id).pluck(:id)
  	Commission.all.each do |c|
  		PositionCommission.create(commission_id: c.id, position_id: 2, percentage: c.percentage)
  		ids.each do |id|
	  		PositionCommission.create(commission_id: c.id, position_id: id, percentage: 0)
  		end
  	end
  end
  def down
  end
end
