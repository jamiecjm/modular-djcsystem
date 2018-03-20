RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    # Apartment::Tenant.drop('app') rescue nil
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
  end

  config.after(:each) do
    # Apartment::Tenant.reset
    DatabaseCleaner.clean
  end

end