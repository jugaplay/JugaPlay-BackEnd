require 'delayed-plugins-airbrake'

Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY']
end

Delayed::Worker.plugins << Delayed::Plugins::Airbrake::Plugin
