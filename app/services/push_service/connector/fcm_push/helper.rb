module PushService
  module Connector
    module FcmPush
      class Helper
        def self.event_type(message_object)
          return :REQUEST_CREATED if message_object.message.message_type_request_offer?
          return :REQUEST_UPDATED if message_object.message.message_type_request_update?

          :OTHER
        end

        def self.notification_title(message_object)
          return I18n.t('push.notifications.request.new.title') if message_object.message.message_type_request_offer?
          return I18n.t('push.notifications.request.update.title') if message_object.message.message_type_request_update?

          message_object.message.text
        end
      end
    end
  end
end