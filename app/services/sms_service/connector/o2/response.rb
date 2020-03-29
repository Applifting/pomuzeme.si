module SmsService
  module Connector
    module O2
      class Response
        attr_reader :response, :raw_response
        delegate :success?, to: :raw_response
        delegate :ref_msg_id, :msg_id, :from_number, :response_description, :text, to: :response

        def initialize(raw_response)
          @raw_response = raw_response
          parse_response
        end

        def to_s
          response.to_s
        end

        private

        def parse_response
          puts '========================'
          puts raw_response
          puts '========================'
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
