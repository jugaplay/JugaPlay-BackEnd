require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JugaplayApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{*/}')]

    config.middleware.insert_before 0, 'Rack::Cors', debug: true, logger: (-> { Rails.logger }) do
      allow do
        origins 'www.miclubhouse.com.ar', 'www.jugaplay.com', 'miclubhouse.com.ar', 'jugaplay.com' , 'm.jugaplay.com' , 'test.jugaplay.com' , 'develop.jugaplay.com', 'develop-front-jp.herokuapp.com', 'localhost', 'jugaplay.dev'
        resource '*',
                 headers: %w(Origin Content-Type Accept Authorization X-CSRF-Token X-Prototype-Version X-Requested-With),
                 methods: [:get, :post, :delete, :put, :patch, :options, :head],
                 credentials: true,
                 max_age: 0
      end
    end

    config.active_job.queue_adapter = :delayed_job
  end
end
