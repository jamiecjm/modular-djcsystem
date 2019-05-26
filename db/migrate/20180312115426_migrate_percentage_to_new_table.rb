class MigratePercentageToNewTable < ActiveRecord::Migration[5.1]
  def up
    return
    default_id = Position.find_by(default: true).id
    Commission.all.each do |c|
      PositionCommission.create(commission_id: c.id, position_id: default_id, percentage: c.percentage)
    end
  end

  def down
  end
end
