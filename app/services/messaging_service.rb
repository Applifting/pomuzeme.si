# frozen_string_literal: true

module MessagingService
  def self.create_message(new_message_args)
    message = Message.create! new_message_args
    Messages::SenderJob.perform_later message.id
  end

  def self.send_message(active_record_message)
    message_object = OutgoingMessage.new(active_record_message)
    klass = message_object.message.sms? ? SmsService : PushService

    klass.send_message(message_object) do |response|
      Callbacks.message_sent(message_object, response)
    end
  rescue StandardError => e
    Raven.extra_context active_record_message: active_record_message.as_json
    Raven.capture_exception e
  end

  def self.callback(event_type, payload)
    Callbacks.send(event_type, payload)
  end
end
