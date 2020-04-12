require_relative 'boot'

%w[
  active_record/railtie
  active_storage/engine
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  rails/test_unit/railtie
  sprockets/railtie
].each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PomuzemeSi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.time_zone = ENV.fetch('TZ_ISO', 'Europe/Prague')

    config.i18n.default_locale = :cs
    config.i18n.available_locales = %i[
      cs
      en
    ]

    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    config.generators do |g|
      g.test_framework :rspec
    end

    config.active_job.queue_adapter = :sidekiq
  end
end

Raven.configure do |config|
  config.current_environment = ENV['ENV_FLAVOR'] || 'development'
end
