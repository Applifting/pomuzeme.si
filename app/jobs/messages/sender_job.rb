module Messages
  class SenderJob < ApplicationJob
    def perform(message_id)
      MessagingService.send(Message.eager_load(:volunteer, :creator, request: :organisation).find(message_id))
    end
  end
end
