RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    Website.create!(subdomain: 'eliteone', superteam_name: 'Eliteone', logo: 'image/upload/v1520436779/wwkyta9njde1rjh0wpn7.png', external_host: 'www.eliteonegroup.com', email: 'website@email.com')

  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end