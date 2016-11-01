ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'rails/all'
require 'rails/test_help'
require 'rspec/rails'
require 'database_cleaner'
require 'devise'
require 'factories'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |file| require file }

# Cleaning configuration
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    ActionMailer::Base.deliveries.clear
  end
end

# Controllers configuration
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include Devise::TestHelpers, type: :controller
  config.include RequestHelpers::Json, type: :controller
  config.include RequestHelpers::Facebook, type: :controller
  config.include PlayerStatsHelpers

  # render json views
  config.render_views

  config.before(:each, type: :controller) do
    # set devise mappings
    request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]

    # set json request headers
    request.headers['Accept'] = Mime::JSON.to_s
    request.headers['Content-Type'] = Mime::JSON.to_s
  end
end
