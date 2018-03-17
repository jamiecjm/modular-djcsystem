require 'devise'
require 'support/macros/controller_macros.rb'
require 'support/request_spec_helper'
RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.extend ControllerMacros, :type => :controller
  config.include RequestSpecHelper, type: :request
end