source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# GIS adapter for pg
gem 'activerecord-postgis-adapter'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
gem 'sprockets', '= 3.7.2'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'best_in_place', '~> 3.1', '>= 3.1.1'

gem 'httparty'

# cloudflare - heroku integration according to https://www.viget.com/articles/heroku-cloudflare-the-right-way/
gem 'rack-attack'
gem 'cloudflare-rails'

gem 'newrelic_rpm'

gem 'sentry-raven'

# heroku metrics
gem 'barnes'

gem 'recaptcha'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry-rails'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
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
  # Fake data
end

group :production do
  gem 'rails_autoscale_agent'
end

gem 'ffaker', '~> 2.14'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Validations
gem 'validates_zipcode'
gem 'phony_rails'

# Code quality
gem 'rubocop'

# authentication
gem 'devise'

# authorization
gem 'cancancan'
gem 'jwt'

# role management
gem 'rolify'

# active admin
gem 'active_admin-humanized_enum'
gem 'activeadmin'
gem 'arctic_admin'
gem 'draper'
gem 'active_admin_datetimepicker'
gem 'activeadmin_json_editor'

# geocoding
gem 'geocoder'

# localisation
gem 'rails-i18n'
gem 'devise-i18n'

# email provider
gem 'sendgrid-ruby'

# data management
gem 'csv'

# serializers
gem 'active_model_serializers'

# push notifications
gem 'rpush'

# background job processing
gem 'sidekiq'

# job locking mechanism
gem 'pg_lock'