module Messages
  class ReceivedProcessorJob < ApplicationJob
    attr_reader :message, :requested_volunteer, :request

    def perform(message)
      @message = message

      # Process response message in context of requested volunteer associations waiting for response
      RequestedVolunteer.eager_load(:request, :volunteer)
                        .where(volunteer_id: message.volunteer_id, state: :notified)
                        .each do |requested_volunteer|
        @requested_volunteer = requested_volunteer
        @request             = requested_volunteer.request

        # Don't process messages for closed requests
        next if @request.closed?

        send_request_not_parsable_response && next unless valid_response?

        Common::Request::ResponseProcessor.new(request, requested_volunteer.volunteer, response).perform
        confirm_response
        mark_message_as_read if rejection_response?

      rescue Common::Request::CapacityExceededError
        capacity_exceeded_response
      end
    end

    private

    def valid_response?
      !response.nil?
    end

    def rejection_response?
      response == false
    end

    def send_request_not_parsable_response
      volunteer = Volunteer.find(message.volunteer_id)
      text      = I18n.t('sms.request.unrecognized')

      SmsService.send_text volunteer.phone, text
      true
    end

    def capacity_exceeded_response
      create_volunteer_message I18n.t('sms.request.over_capacity', identifier: request.identifier)
    end

    def mark_message_as_read
      @message.mark_as_read
    end

    def confirm_response
      msg_type = response ? 'sms.request.confirmed' : 'sms.request.rejected'
      create_volunteer_message I18n.t(msg_type, identifier: request.identifier)
    end

    def create_volunteer_message(text)
      MessagingService.create_and_send_message direction: :outgoing,
                                               message_type: :other,
                                               channel: :sms,
                                               text: text,
                                               phone: requested_volunteer.phone,
                                               volunteer_id: message.volunteer_id,
                                               request: request
    end

    def response
      return @response if defined? @response

      normalized_message = message.text.strip.downcase
      @response = true if normalized_message == 'ano'
      @response = false if normalized_message == 'ne'
      @response
    end
  end
end
