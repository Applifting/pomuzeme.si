module SmsService
  module Connector
    module O2
      def self.send_message(phone, text)
        Message.send(phone, text)
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

      class Response
        def initialize(raw_response)
          parse_response raw_response
        end

        def parse_response(raw_response)
          @response = raw_response.to_s.split("\n").map { |i| i.split('=') }.to_h
        end
      end
    end
  end
end
