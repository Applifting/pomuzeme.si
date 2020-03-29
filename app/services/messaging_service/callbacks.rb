# frozen_string_literal: true

module MessagingService
  module Callbacks
    class << self
      def message_sent(message_object, response)
        message_object.message.update channel_msg_id: response.ref_msg_id,
                                      channel: :sms,
                                      state: :sent
      end

      def delivery_report_received(adapter_response)
        message = Message.find_by!(channel_msg_id: adapter_response.ref_msg_id)
        message.update read_at: adapter_response.timestamp,
                       state: :received
      end

      def message_received(adapter_response)
        volunteer = Volunteer.find_by!(phone: adapter_response.from_number)

        Message.create volunteer: volunteer,
                       text: adapter_response.text,
                       direction: :incoming,
                       state: :received,
                       channel: :sms
      end
    end
  end
end
