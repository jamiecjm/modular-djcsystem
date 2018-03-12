class MigratePercentageToNewTable < ActiveRecord::Migration[5.1]
  def up
  	Commission.all.each do |c|
  		PositionCommission.create(commission_id: c.id, position_id: 2, percentage: c.percentage)
  		PositionCommission.create(commission_id: c.id, position_id: 1, percentage: 0)
  		PositionCommission.create(commission_id: c.id, position_id: 3, percentage: 0)
  		PositionCommission.create(commission_id: c.id, position_id: 4, percentage: 0)
  	end
  end
  def down
  end
end
