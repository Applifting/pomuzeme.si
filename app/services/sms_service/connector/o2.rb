module SmsService
  module Connector
    module O2
      MESSAGE_DELIVERED_TO_NETWORK = 'ISUC_010'.freeze
      BA_ID                        = ENV['O2_BA_ID']
      PHONE_NUMBER                 = ENV['O2_PHONE_NUMBER']

      def self.send_message(phone, text, delivery_report:)
        Message.send(phone, text, delivery_report: delivery_report)
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

        attr_accessor :o2_auth_pass, :o2_auth_key, :o2_auth_crt

        def initialize
          @o2_auth_key  = ENV['O2_AUTH_KEY']
          @o2_auth_crt  = ENV['O2_AUTH_CRT']
          @o2_auth_pass = ENV['O2_AUTH_PASS']

          unless ENV['SMS_MOCK'] == 'true'
            check_config
            set_p12_cert!
          end
        end

        def self.init
          new
          self
        end

        private

        def set_p12_cert!
          p12 = OpenSSL::PKCS12.create(o2_auth_pass, 'auth',
                                       OpenSSL::PKey.read(o2_auth_key),
                                       OpenSSL::X509::Certificate.new(o2_auth_crt))
          self.class.pkcs12 p12.to_der, o2_auth_pass
        end

        def check_config
          errors = required_config.map { |k, v| k if v.blank? }.compact
          text   = 'config missing: ' + errors.map(&:upcase).join(', ')
          raise ConfigurationError, text if errors.present?
        end

        def required_config
          {
            o2_auth_key: o2_auth_key,
            o2_auth_pass: o2_auth_pass,
            o2_auth_crt: o2_auth_crt
          }
        end
      end
    end
  end
end
