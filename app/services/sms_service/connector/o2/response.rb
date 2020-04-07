module SmsService
  module Connector
    module O2
      class Response
        MESSAGE_DELIVERED_TO_NETWORK = 'ISUC_010'.freeze
        MESSAGE_DELIVERED_TO_PHONE   = 'ISUC_005'.freeze

        # Required methods
        # :channel_msg_id, :from_number, :text, :delivery_receipt_timestamp

        attr_reader :response, :raw_response
        delegate :success?, to: :raw_response
        delegate :ref_msg_id, :msg_id, :from_number, :response_description,
                 :selector, :timestamp, :response_code, :text, to: :response

        alias channel_msg_id ref_msg_id
        alias delivery_receipt_timestamp timestamp

        def initialize(raw_response)
          @raw_response = raw_response
          @response     = parsed_response

          report_error if response&.error_report?
        end

        def blank?
          response.ba_id.nil?
        end

        def error_report?
          message_type == :error_message
        end

        def message_type
          return :message_received if selector == 'TextSms'

          case response_code
          when MESSAGE_DELIVERED_TO_PHONE
            :delivery_report_received
          end
        end

        def ignore?
          response_code == MESSAGE_DELIVERED_TO_NETWORK
        end

        def to_s
          response.to_s
        end

        private

        def report_error
          Raven.extra_context parsed_response: parsed_response.to_s
          Raven.capture_exception 'O2 error response'
        end

        def parsed_response
          OpenStruct.new raw_response.to_s
                                     .split("\n")
                                     .map(&:strip)
                                     .map { |i| i.split('=') }
                                     .reject { |i| i[1].blank? }
                                     .to_h
                                     .transform_keys(&:underscore)
        end
      end
    end
  end
end
