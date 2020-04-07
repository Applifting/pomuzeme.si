module SmsService
  class MessagingError < StandardError; end

  module Connector
    module O2
      class Message
        attr_reader :phone, :text, :request_delivery_report

        def initialize(phone, text, delivery_report: nil)
          @phone = phone
          @text  = I18n.transliterate text
          @request_delivery_report = delivery_report
        end

        def self.receive
          raw_response = O2.client.get('/smsconnector/getpost/GP', { query: { action: 'receive', baID: O2::BA_ID } })
          response = handle_response(raw_response)
          block_given? ? yield(response) : response
        end

        def self.confirm(incoming_msg)
          confirm_query = {
            action: 'confirm',
            baID: O2::BA_ID,
            refBaID: O2::BA_ID,
            refMsgID: incoming_msg.msg_id
          }

          raw_response = O2.client.get('/smsconnector/getpost/GP', { query: confirm_query })
          handle_response(raw_response)
        end

        def self.send(phone, text, delivery_report:)
          new(phone, text, delivery_report: delivery_report).send
        end

        def send(attempt = 0)
          raw_response = if ENV['SMS_MOCK'] == 'true'
                           send_mock_message
                         else
                           O2.client.get('/smsconnector/getpost/GP', { query: send_query })
                         end

          # If request returns no success code try it again after 100ms
          if raw_response.code > 299 && attempt < 1
            sleep 0.2
            send(1)
          end

          handle_response(raw_response)
        end

        def self.handle_response(raw_response)
          parsed_response = Response.new raw_response
          parsed_response.success? ? parsed_response : handle_error(parsed_response)
        end

        def self.handle_error(parsed_response)
          raise SmsService::MessagingError, parsed_response.response_description
        end

        private

        def handle_response(raw_response)
          self.class.handle_response raw_response
        end

        def handle_error(parsed_response)
          self.class.handle_error parsed_response
        end

        def send_mock_message
          puts '==========================='
          puts "SMS for #{phone}, TEXT -> #{text}"
          puts '==========================='

          mock_raw_response_success
        end

        def mock_raw_response_success
          "selector=Response\nresponseType=SUCCESS\nresponseCode=ISUC_001\nresponseDescription=Pozadavek Send uspesne zpracovan - ISUC_001 - Send request successfully processed\nbaID=1992125\nrefBaID=1992125\nmsgID=ID-48555-1585223320437-1-2900914\ntimestamp=2020-03-29T13:35:00\nrefMsgID=ID-48555-1585223320437-1-2900913\n"
        end

        def send_query
          {
            action: 'send',
            baID: O2::BA_ID,
            fromNumber: O2::PHONE_NUMBER,
            toNumber: phone,
            text: text,
            deliveryReport: request_delivery_report,
            intruder: 'FALSE',
            multipart: 'TRUE',
            validityPeriod: 10_000,
            priority: 1
          }
        end

        def confirm_query(incoming_msg)
          {
            action: 'receive',
            baID: O2::BA_ID,
            refBaID: O2::BA_ID,
            refMsgID: incoming_msg.msg_id
          }
        end
      end
    end
  end
end
