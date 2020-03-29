module SmsService
  module Connector
    module O2
      class Message
        attr_reader :phone, :text

        def initialize(phone, text)
          @phone = phone
          @text  = text
        end

        def self.send(phone, text)
          new(phone, text).send
        end

        def send(attempt = 0)
          return send_mock_message if ENV['SMS_MOCK'] == 'true'

          raw_response = O2.client.get('/smsconnector/getpost/GP', { query: send_query })

          # If request returns no success code try it again after 100ms
          if raw_response.code > 299 && attempt < 1
            sleep 0.1
            send(1)
          end

          Response.new raw_response
        end

        def receive_msg
          raw_response = self.class.get('/smsconnector/getpost/GP', { query: receive_query })
        end

        private

        def send_mock_message
          puts '==========================='
          puts "SMS for #{phone}, TEXT -> #{text}"
          puts '==========================='
          Response.new mock_raw_response_success
        end

        def mock_raw_response_success
          "selector=Response\nresponseType=SUCCESS\nresponseCode=ISUC_001\nresponseDescription=Pozadavek Send uspesne zpracovan - ISUC_001 - Send request successfully processed\nbaID=1992125\nrefBaID=1992125\nmsgID=ID-48555-1585223320437-1-2900914\ntimestamp=2020-03-29T13:35:00\nrefMsgID=ID-48555-1585223320437-1-2900913\n"
        end

        def send_query
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

        def receive_query
          {
            action: 'send',
            baID: 1_992_125,
            fromNumber: '+420720002125',
            toNumber: '',
            text: '',
            deliveryReport: 'FALSE',
            intruder: 'FALSE',
            multipart: 'FALSE',
            validityPeriod: 10_000,
            priority: 1
          }
        end
      end
    end
  end
end
