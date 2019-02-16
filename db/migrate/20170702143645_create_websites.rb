class CreateWebsites < ActiveRecord::Migration[5.0]
  def change
    create_table :websites do |t|
    	t.string	:subdomain
      t.timestamps
    end
  end
end
