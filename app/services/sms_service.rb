# frozen_string_literal: true

module SmsService
  attr_reader :connector

  def self.send_message(message_object)
    response = Connector::O2.send_message(message_object.phone,
                                          message_object.text,
                                          delivery_report: ENV['DISABLE_SMS_RECEIVER'] != 'true')

    block_given? ? yield(response) : response
  end

  def self.send_text(phone, text)
    Connector::O2.send_message(phone, text, delivery_report: false)
  end

  def self.receive
    Connector::O2.receive_message
  end
end
