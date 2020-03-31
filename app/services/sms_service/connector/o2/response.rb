module SmsService
  module Connector
    module O2
      class Response
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
          parse_response
        end

        def blank?
          response.ba_id.nil?
        end

        def to_s
          response.to_s
        end

        private

        def parse_response
          @response = OpenStruct.new raw_response.to_s
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
