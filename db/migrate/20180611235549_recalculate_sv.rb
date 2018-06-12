class RecalculateSv < ActiveRecord::Migration[5.1]
  def change
    Salevalue.all.each do |sv|
      sv.save
    end
  end
end
