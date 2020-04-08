module Messages
  class ReceiverJob < ApplicationJob
    queue_as :receiver_queue

    around_perform do |job, block|
      block.call
    rescue StandardError => e
      Raven.capture_exception e
    ensure
      Messages::ReceiverJob.perform_later unless already_performing? || already_enqueued?
    end

    def perform
      Rails.logger.debug 'Performing MessageReceiverJob'

      if Rails.env.production? || ENV['RECEIVE_MESSAGES'] == 'true'
        SmsService.receive
      else
        puts 'Calling receiver service'
        sleep 10
      end
    end

    private

    def already_performing?
      Sidekiq::Workers.new.to_a.any? do |worker|
        data = worker.try :[], 2 # data are third element of worker array
        (data&.dig('payload', 'queue') == 'receiver_queue') && (data&.dig('payload', 'jid') != provider_job_id)
      end
    end

    def already_enqueued?
      Sidekiq::ScheduledSet.new.scan("Messages::ReceiverJob").any?
    end
  end
end
