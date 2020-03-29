module SmsService
  module Connector
    class O2
      include HTTParty
      base_uri ENV['O2_BASE_URL']

      class Response
        attr_reader :response

        def initialize(raw_response)
          parse_response raw_response
        end

        def parse_response(raw_response)
          @response = raw_response.to_s.split("\n").map { |i| i.split('=') }.to_h
        end
      end

      def initialize
        set_p12_cert! unless ENV['SMS_MOCK'] == 'true'
      end

      def send_msg(phone, text, attempt = 0)
        return send_mock_message(phone, text) if ENV['SMS_MOCK'] == 'true'

        raw_response = self.class.get('/smsconnector/getpost/GP', { query: send_query(phone, text) })

        # If request returns no success code try it again after 100ms
        if raw_response.code > 299 && attempt < 1
          sleep 0.1
          send_msg(phone, text, 1)
        end

        Response.new raw_response
      end

      def receive_msg
        raw_response = self.class.get('/smsconnector/getpost/GP', { query: send_query(phone, text) })
      end

      private

      def send_mock_message(phone, text)
        puts "SMS for #{phone}, TEXT -> #{text}"
        Response.new mock_raw_response_success
      end

      def mock_raw_response_success
        "selector=Response\nresponseType=SUCCESS\nresponseCode=ISUC_001\nresponseDescription=Pozadavek Send uspesne zpracovan - ISUC_001 - Send request successfully processed\nbaID=1992125\nrefBaID=1992125\nmsgID=ID-48555-1585223320437-1-2900914\ntimestamp=2020-03-29T13:35:00\nrefMsgID=ID-48555-1585223320437-1-2900913\n"
      end

      def send_query(phone, text)
        {
          action: 'send',
          baID: 1_992_125,
          fromNumber: '+420720002125',
          toNumber: phone,
          text: text,
          deliveryReport: 'FALSE',
          intruder: 'FALSE',
          multipart: 'FALSE',
          validityPeriod: 10_000,
          priority: 1
        }
      end

      def send_query(phone, text)
        {
          action: 'send',
          baID: 1_992_125,
          fromNumber: '+420720002125',
          toNumber: phone,
          text: text,
          deliveryReport: 'FALSE',
          intruder: 'FALSE',
          multipart: 'FALSE',
          validityPeriod: 10_000,
          priority: 1
        }
      end

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
