module Messages
  class SenderJob < ApplicationJob
    queue_as :sender_queue

    def perform(message_id)
      MessagingService.send(Message.eager_load(:volunteer, :creator, request: :organisation).find(message_id))
    end
  end
end
