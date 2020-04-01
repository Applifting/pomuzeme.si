class MessageReceiverJob < ApplicationJob
  def perform
    Rails.logger.debug 'Performing MessageReceiverJob'
    # MessageReceiverJob.set(wait: 15.seconds).perform_later

    if Rails.env.production?
      SmsService.receive
    else
      puts "Calling receiver service"
    end
  end
end