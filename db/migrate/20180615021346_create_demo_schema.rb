class CreateDemoSchema < ActiveRecord::Migration[5.1]
  
  def up
    Apartment::Tenant.create('demo')
  end

  def down
    Apartment::Tenant.drop('demo')
  end

end
