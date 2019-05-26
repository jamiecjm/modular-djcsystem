class CreateDemoSchema < ActiveRecord::Migration[5.1]
  def up
    return
    Apartment::Tenant.create("demo")
  end

  def down
    Apartment::Tenant.drop("demo")
  end
end
