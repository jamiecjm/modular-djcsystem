class AddWebsiteColumn < ActiveRecord::Migration[5.0]
  def change
  	add_column :websites, :superteam_name,	:string
  	add_column :websites, :logo, :string
  end
end
