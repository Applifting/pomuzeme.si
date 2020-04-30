Rails.logger.debug Rails.env
return if Rails.env.test?

require 'sidekiq/api'

Sidekiq.configure_client do |_config|
  Rails.application.config.after_initialize do
    return if ENV['DISABLE_SMS_RECEIVER'] = 'true'

    Messages::ReceiverJob.perform_later
  end
end
