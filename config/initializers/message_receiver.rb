Rails.logger.debug 'initializer started'
# return unless defined?(Rails::Server)
Rails.logger.debug 'rails server defined'

require 'sidekiq/api'

Sidekiq.configure_client do |_config|
  Rails.logger.debug 'configuring client'
  Rails.application.config.after_initialize do
    Rails.logger.debug 'application initialized'

    Messages::ReceiverJob.perform_later
  end
end