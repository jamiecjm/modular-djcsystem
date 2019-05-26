class SetStatusDefault < ActiveRecord::Migration[5.1]
  def up
    change_column :sales, :status, :string, default: "Booked"
    return
    Sale.where(status: nil).each do |s|
      s.update(status: "Booked")
    end
  end

  def down
  end
end
