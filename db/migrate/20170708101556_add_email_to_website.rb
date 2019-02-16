class AddEmailToWebsite < ActiveRecord::Migration[5.0]
  def change
  	add_column	:websites, :email, :string
  	add_column	:websites, :password, :string
  	add_column	:websites, :password_digest, :string
  end
end
