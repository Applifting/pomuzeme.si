# frozen_string_literal: true

module MessagingService
  module Callbacks
    # adapter_response required methods
    # :channel_msg_id, :from_number, :text, :delivery_receipt_timestamp

    class << self
      def message_sent(message_object, response)
        message = message_object.message
        requested_volunteer = RequestedVolunteer.find_by request_id: message.request_id,
                                                         volunteer_id: message.volunteer_id

        message.update! channel_msg_id: response.channel_msg_id,
                        state: :sent
        requested_volunteer&.notified! if message.message_type_request_offer?
      end

      def delivery_report_received(adapter_response)
        message = Message.find_by(channel_msg_id: adapter_response.channel_msg_id)

        return unless message

        message.update read_at: adapter_response.delivery_receipt_timestamp,
                       state: :received
      end

      def message_received(adapter_response)
        volunteer = Volunteer.find_by(phone: adapter_response.from_number)
        requests  = Request.where(subscriber_phone: adapter_response.from_number).pluck(:id) if volunteer.blank?

        return true unless volunteer || requests.present?

        message = Message.create! volunteer: volunteer,
                                  phone: adapter_response.from_number,
                                  text: adapter_response.text,
                                  direction: :incoming,
                                  message_type: (requests.present? ? :subscriber : :other),
                                  state: :received,
                                  channel: :sms

        Messages::ReceivedProcessorJob.perform_later(message) if volunteer
        true
      end
    end
  end
end
