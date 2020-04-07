# frozen_string_literal: true

module SmsService
  attr_reader :connector

  def self.send(message_object)
    response = Connector::O2.send_message(message_object.phone, message_object.text, delivery_report: true)

    block_given? ? yield(response) : response
  end

  def self.send_text(phone, text)
    Connector::O2.send_message(phone, text, delivery_report: false)
  end

  def self.receive
    Connector::O2.receive_message
  end

  def self.replace_special_chars(text)
    text.tr('ěščřžýáíéúůťďóňĚŠČŘŽÝÁÍÉÚŮŤĎÓŇ', 'escrzyaieuutdonESCRZYAIEUUTDON')
  end
end
