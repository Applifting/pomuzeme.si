# frozen_string_literal: true

module MessagingService
  def self.send(message_object)
    # Send message
    # On success, mark the RequestedVolunteer status to notified (if it's a first message to the volunteer within the request)
    Sms::O2Connector.new.send_msg(message_object.volunteer.phone, message_object.text)
  end

  def self.receive(incoming_msg_object); end
end
