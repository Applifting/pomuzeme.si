# frozen_string_literal: true

module PushService

  def self.send_message(message_object)
    response = connector.send_message resolve_payload_data(message_object),
                                      resolve_notification_data(message_object),
                                      message_object.fcm_token

    block_given? ? yield(response) : response
  end

  def self.handle_response(notification_object)
    connector.handle_response notification_object
  end

  def self.resolve_payload_data(message_object)
    { event: connector.helper.event_type(message_object),
      request_id: message_object.request.id }
  end

  def self.resolve_notification_data(message_object)
    { title: connector.helper.notification_title(message_object),
      body: message_object.message.text }
  end

  def self.connector
    Connector::FcmPush
  end
end
