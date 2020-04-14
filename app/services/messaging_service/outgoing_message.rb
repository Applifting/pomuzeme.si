module MessagingService
  class OutgoingMessage
    attr_reader :phone, :message, :fcm_token, :request

    def initialize(active_record_message)
      @phone = active_record_message&.volunteer&.phone
      @fcm_token = active_record_message&.volunteer&.fcm_token
      @text = active_record_message.text
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