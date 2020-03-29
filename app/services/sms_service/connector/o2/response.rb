module SmsService
  module Connector
    module O2
      class Response
        attr_reader :response

        def initialize(raw_response)
          parse_response raw_response
        end

        def type; end

        def incoming_text?; end

        private

        def parse_response(raw_response)
          @response = raw_response.to_s
                                  .split("\n")
                                  .map(&:strip)
                                  .map { |i| i.split('=') }
                                  .reject { |i| i[1].blank? }
                                  .to_h
        end
      end
    end
  end
end
