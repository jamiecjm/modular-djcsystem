RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    Apartment::Tenant.drop('1') rescue nil
    Apartment::Tenant.drop('2') rescue nil
    Apartment::Tenant.drop('3') rescue nil
    FactoryBot.create(:website)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    FactoryBot.create(:default_position)
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    # Apartment::Tenant.switch! '1'
  end

  config.after(:each) do
    # Apartment::Tenant.reset
    DatabaseCleaner.clean
  end

end