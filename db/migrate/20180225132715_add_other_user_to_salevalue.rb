class AddOtherUserToSalevalue < ActiveRecord::Migration[5.1]
  def up
  	add_column :salevalues, :other_user, :string

  	User.where(team_id: nil).each do |u|
  		u.salevalues.each do |sv|
  			sv.update(user_id: nil, other_user: u.prefered_name)
  		end
  	end
  end

  def down
  	remove_column :salevalues, :other_user
  end
end
