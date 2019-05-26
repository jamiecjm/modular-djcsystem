class RecalcSv < ActiveRecord::Migration[5.1]
  def up
    return
    Salevalue.where(comm: nil).each do |sv|
      sv.recalc_comm
    end
  end

  def down
  end
end
