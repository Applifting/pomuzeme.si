require 'rails_helper'

describe PushService do
  before(:all) { I18n.locale = :cs }

  let(:message) { create :message, request: create(:request) }
  let(:outgoing_message) { MessagingService::OutgoingMessage.new message }

  describe '.send_message' do
    it 'sends message via default connector' do
      expect(PushService::Connector::FcmPush).to receive(:send_message).with(PushService.resolve_payload_data(outgoing_message),
                                                                             PushService.resolve_notification_data(outgoing_message),
                                                                             outgoing_message.fcm_token)
      PushService.send_message outgoing_message
    end

    it 'returns connector response if no block given' do
      expect(PushService::Connector::FcmPush).to receive(:send_message).and_return('foobar')
      expect(PushService.send_message outgoing_message).to eq 'foobar'
    end

    it 'yields connector response if block given' do
      expect(PushService::Connector::FcmPush).to receive(:send_message).and_return('foobar')
      PushService.send_message outgoing_message do |response|
        expect(response).to eq 'foobar'
      end
    end
  end

  describe '.handle_response' do
    it 'delegates response handling to connector' do
      expect(PushService.connector).to receive(:handle_response).with(42)
      PushService.handle_response 42
    end
  end

  describe '.resolve_payload_data' do
    it 'resolves payload data correctly' do
      message.message_type_request_offer!
      payload = PushService.resolve_payload_data outgoing_message
      expect(payload[:event]).to eq PushService.connector.helper.event_type(outgoing_message)
      expect(payload[:request_id]).to eq message.request_id
    end
  end

  describe '.resolve_notification_data' do
    it 'resolves notification data correctly' do
      message.message_type_request_offer!
      payload = PushService.resolve_notification_data outgoing_message
      expect(payload[:title]).to eq PushService.connector.helper.notification_title(outgoing_message)
      expect(payload[:body]).to eq message.text
    end
  end

  describe '.connector' do
    it 'returns default connector' do
      expect(PushService.connector).to eq PushService::Connector::FcmPush
    end
  end
end
