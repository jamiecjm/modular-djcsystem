class AddHostColumn < ActiveRecord::Migration[5.0]
  def change
  	add_column :websites, :external_host, :string 
  end
end
