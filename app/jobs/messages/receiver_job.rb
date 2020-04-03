module Messages
  class ReceiverJob < ApplicationJob
    queue_as :receiver_queue

    def perform
      Rails.logger.debug 'Performing MessageReceiverJob'
      Messages::ReceiverJob.set(wait: 31.seconds).perform_later

      if Rails.env.production? || ENV['RECEIVE_MESSAGES'] == 'true'
        SmsService.receive
      else
        puts 'Calling receiver service'
      end
    end
  end
end
