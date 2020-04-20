module PushService
  class MessagingError < StandardError; end

  module Connector
    module FcmPush
      class Message
        attr_reader :payload, :notification, :fcm_token

        def initialize(payload, notification, fcm_token)
          @payload = payload
          @notification = notification
          @fcm_token = fcm_token
        end

        def self.send(payload, notification, fcm_token)
          new(payload, notification, fcm_token).send
        end

        def send
          response = Client.send payload, notification, [fcm_token]
          handle_response response
        end

        def self.handle_response(raw_response)
          parsed_response = Response.new raw_response
          parsed_response.success? ? parsed_response : handle_error(parsed_response)
        end

        def self.handle_error(parsed_response)
          Raven.extra_context parsed_response: parsed_response.to_s
          raise PushService::MessagingError, parsed_response.error_description
        end

        private

        def handle_response(raw_response)
          self.class.handle_response raw_response
        end

        def handle_error(parsed_response)
          self.class.handle_error parsed_response
        end
      end
    end
  end
end
