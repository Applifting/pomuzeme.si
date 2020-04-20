module PushService
  module Connector
    module FcmPush
      class Response
        ERROR_MESSAGE_TYPE = :error_message
        # Required methods
        # :channel_msg_id, :from_number, :text, :delivery_receipt_timestamp

        attr_reader :response
        delegate :error_description, to: :response

        def initialize(notification_response)
          @response = notification_response
        end

        def channel_msg_id
          response.id
        end

        def from_number
          response.registration_ids&.first
        end

        def text
          response.notification['body']
        end

        def delivery_receipt_timestamp
          response.delivered_at
        end

        def message_type
          return :delivery_report_received if response.delivered?
          return :message_sent unless response.failed?

          ERROR_MESSAGE_TYPE
        end

        def success?
          message_type != ERROR_MESSAGE_TYPE
        end

        def to_s
          response.to_s
        end

        private

        def report_error
          Raven.extra_context parsed_response: response.to_json
          Raven.capture_exception 'FcmPush error response'
        end
      end
    end
  end
end
