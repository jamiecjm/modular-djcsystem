class ChangeIcIntegerLimit < ActiveRecord::Migration[5.1]
  def up
  	change_column :users, :ic_no, :string
  end

  def down
  	change_column :users, :ic_no, :integer
  end
end
