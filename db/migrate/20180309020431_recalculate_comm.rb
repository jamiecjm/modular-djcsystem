class RecalculateComm < ActiveRecord::Migration[5.1]
  def up
    return
    Sale.where("date >= ?", "2018-3-1".to_date).each do |s|
      s.set_comm
      s.save
    end
  end

  def down
  end
end
