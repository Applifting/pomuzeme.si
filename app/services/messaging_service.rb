# frozen_string_literal: true

module MessagingService
  def self.send(active_record_message)
    # create message_object shared with / understood by SMSService, PushNotificationService
    message_object = OutgoingMessage.new(active_record_message)

    # detect channel (sms / app)
    # delegate message sending to required channel service
    SmsService.send(message_object) do |response|
      Callbacks.message_sent(message_object, response)
    end
  rescue StandardError => e
    # TODO: cleanup
    puts e
    puts e.backtrace[0..10]
    Raven.capture_exception e
  end

  # Receive callbacks: message_received, message_sent, delivery_report_received
  def self.callback(event_type, payload)
    Callbacks.send(event_type, payload)
  end

  class OutgoingMessage
    # expose attributes needed to:
    # - send message
    # - decorate message text (creator's signature, ...)

    attr_reader :phone, :message

    def initialize(active_record_message)
      @phone   = active_record_message&.volunteer&.phone
      @text    = active_record_message.text
      @creator = active_record_message.creator
      @request_organisation = active_record_message&.request&.organisation
      @request = active_record_message&.request
      @message = active_record_message
    end

    def text
      "#{@text} [#{creator_signature}]"
    end

    def creator_signature
      [@creator.to_s, @request_organisation.name].compact.join(', ')
    end
  end
end
