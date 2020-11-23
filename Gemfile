source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

## 3rd party integrations and integration enablers
gem 'httparty'
gem 'recaptcha'
gem 'rpush'
gem 'sendgrid-ruby'
gem 'slack-ruby-client'


## Active admin
gem 'active_admin-humanized_enum'
gem 'activeadmin'
gem 'arctic_admin'
gem 'best_in_place'
gem 'draper'
gem 'active_admin_datetimepicker'
gem 'activeadmin_json_editor'


# Authentication, authorization & friends
gem 'devise'
gem 'cancancan'
gem 'jwt'
gem 'rolify' # role management


## Background job processing
gem 'sidekiq'
gem 'sidekiq-scheduler'


## Cloud operations
gem 'barnes' # heroku metrics
gem 'newrelic_rpm'
gem 'rack-attack'      # cloudflare - heroku integration according to https://www.viget.com/articles/heroku-cloudflare-the-right-way/
gem 'cloudflare-rails' # cloudflare - heroku integration according to https://www.viget.com/articles/heroku-cloudflare-the-right-way/
gem 'sentry-raven'
gem 'rails_autoscale_agent', '>= 0.9.1', group: :production


## Database related gems
gem 'active_model_serializers'
gem 'activerecord-postgis-adapter'
gem 'nilify_blanks'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pg_lock'
gem 'phony_rails'
gem 'validates_zipcode'


## Rails & friends
gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
gem 'puma', '~> 4.3'


## Front-end stuff
gem 'sass-rails', '>= 6'
gem 'sprockets', '= 3.7.2'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder


## Miscellaneous
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.2', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'geocoder' # geocoding
gem 'rails-i18n' # localisation
gem 'devise-i18n' # localisation
# data management
gem 'csv'


group :development, :test do
  gem 'ffaker', '~> 2.14'
  gem 'pry-rails'
  gem 'rubocop'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'therubyracer'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'

  # Support for testing
  gem 'rspec-rails', '~> 3.9'
  gem 'factory_bot_rails', '~> 5.1'
  # More performant tests
  gem 'test-prof', '~> 0.10'
  # One liner matchers
  gem 'shoulda-matchers', '~> 4.3'
  # Check coverage
  gem 'simplecov', require: false
  gem 'codecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
