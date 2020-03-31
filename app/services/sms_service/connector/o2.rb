module SmsService
  module Connector
    module O2
      MESSAGE_DELIVERED_TO_NETWORK = 'ISUC_010'.freeze
      BA_ID                        = 1_992_125
      PHONE_NUMBER                 = '+420720002125'.freeze

      def self.send_message(phone, text)
        Message.send(phone, text)
      end

      def self.receive_message
        Message.receive do |incoming_message|
          next if incoming_message.blank?

          confirm(incoming_message) && next if incoming_message&.response_code == MESSAGE_DELIVERED_TO_NETWORK

          event_type = incoming_message.selector == 'Response' ? :delivery_report_received : :message_received

          confirm(incoming_message) if MessagingService.callback(event_type, incoming_message)
        end
      end

      def self.confirm(message_response)
        Message.confirm message_response
      end

      def self.client
        @client ||= Client.init
      end

      class Client
        include HTTParty
        base_uri ENV['O2_BASE_URL']

        def initialize
          set_p12_cert! unless ENV['SMS_MOCK'] == 'true'
        end

        def self.init
          new
          self
        end

        private

        def set_p12_cert!
          pass = ENV['O2_AUTH_PASS']
          key = ENV['O2_AUTH_KEY']
          crt = ENV['O2_AUTH_CRT']

          p12 = OpenSSL::PKCS12.create(pass, 'auth', OpenSSL::PKey.read(key), OpenSSL::X509::Certificate.new(crt))
          self.class.pkcs12 p12.to_der, pass
        end
      end
    end
  end
end
