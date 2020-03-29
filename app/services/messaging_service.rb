# frozen_string_literal: true

module MessagingService
  def self.send(active_record_message)
    # create message_object shared with / understood by SMSService, PushNotificationService
    message_object = OutgoingMessage.new(active_record_message)

    # detect channel (sms / app)
    # delegate message sending to required channel service
    ::SmsService.send(message_object)
  end

  def self.send_callback(message_object); end

  def self.callback(event_type)
    # case event_type
    # when :delivery_report_received
    # when :message_received
    # when :request_accepted
    # when :request_rejected
    # end
  end

  class OutgoingMessage
    # expose attributes needed to:
    # - send message
    # - decorate message text (creator's signature, ...)

    attr_reader :phone

    def initialize(active_record_message)
      @phone   = active_record_message&.volunteer&.phone
      @text    = active_record_message.text
      @creator = active_record_message.creator
      @request_organisation = active_record_message&.request&.organisation
      @request = active_record_message&.request
    end

    def text
      "#{@text} [#{creator_signature}]"
    end

    def creator_signature
      [@creator.to_s, @request_organisation.name].compact.join(', ')
    end
  end
end
