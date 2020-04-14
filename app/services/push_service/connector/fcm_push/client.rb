module PushService
  module Connector
    module FcmPush
      class Client
        def self.send(payload_data, notification_data, receivers)
          Rpush::Gcm::Notification.new.tap do |n|
            n.app = Rpush::Gcm::App.find_by_name 'test_app' #(ENV['PUSH_APP_NAME'])
            n.registration_ids = receivers
            n.data = payload_data.merge flutter_payload
            n.priority = 'normal'
            n.content_available = true
            n.notification = notification_data
            n.save!
          end
        end

        def self.flutter_payload
          { click_action: 'FLUTTER_NOTIFICATION_CLICK' }.freeze
        end
      end
    end
  end
end