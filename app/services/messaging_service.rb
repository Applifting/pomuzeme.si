# frozen_string_literal: true

module MessagingService
  def self.send(active_record_message)
    message_object = OutgoingMessage.new(active_record_message)

    SmsService.send(message_object) do |response|
      Callbacks.message_sent(message_object, response)
    end
  rescue StandardError => e
    Raven.extra_context active_record_message: active_record_message
    Raven.capture_exception e
  end

  def self.callback(event_type, payload)
    Callbacks.send(event_type, payload)
  end

  class OutgoingMessage
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
      [
        @text,
        ("[#{creator_signature}]" if message_has_creator?)
      ].join(' ')
    end

    def message_has_creator?
      message.creator.present?
    end

    def creator_signature
      [@creator.to_s, @request_organisation&.name].compact.join(', ')
    end
  end
end
