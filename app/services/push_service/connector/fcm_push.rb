module PushService
  module Connector
    module FcmPush

      def self.send_message(payload, notification, fcm_token)
        Message.send payload, notification, fcm_token
      end

      def self.handle_response(notification_object)
        response = Message.handle_response notification_object
        MessagingService.callback response.message_type, response
      end

      def self.client
        Client
      end

      def self.helper
        Helper
      end
    end
  end
end
