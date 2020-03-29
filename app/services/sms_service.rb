# frozen_string_literal: true

module SmsService
  def self.send(decorated_message_object)
    response = connector.send_msg(decorated_message_object.phone, decorated_message_object.text)
  end

  def self.connector
    @@connector ||= SmsService::Connector::O2.new
  end

  def self.receive(incoming_msg_object); end
end
