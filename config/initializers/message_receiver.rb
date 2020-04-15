require 'sidekiq/api'

Sidekiq.configure_client do |_config|
  Rails.application.config.after_initialize do
    Messages::ReceiverJob.perform_later
  end
end