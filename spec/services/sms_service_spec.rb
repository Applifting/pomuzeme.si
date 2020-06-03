require 'rails_helper'

describe SmsService do
  before(:all) { I18n.locale = :cs }

  let(:message) { create :message }
  let(:outgoing_message) { MessagingService::OutgoingMessage.new message }

  describe '.send_message' do
    it 'sends message via default connector with delivery report' do
      expect(SmsService::Connector::O2).to receive(:send_message).with(outgoing_message.phone, outgoing_message.text, delivery_report: true)
      SmsService.send_message outgoing_message
    end

    it 'returns connector response if no block given' do
      expect(SmsService::Connector::O2).to receive(:send_message).and_return('foobar')
      expect(SmsService.send_message outgoing_message).to eq 'foobar'
    end

    it 'yields connector response if block given' do
      expect(SmsService::Connector::O2).to receive(:send_message).and_return('foobar')
      SmsService.send_message outgoing_message do |response|
        expect(response).to eq 'foobar'
      end
    end
  end

  describe '.send_text' do
    it 'sends message via default connector without delivery report' do
      expect(SmsService::Connector::O2).to receive(:send_message).with('123456789', 'hello world', delivery_report: false)
      SmsService.send_text '123456789', 'hello world'
    end
  end

  describe '.receive' do
    it 'calls receiver method on default connector' do
      expect(SmsService::Connector::O2).to receive(:receive_message).with(no_args)
      SmsService.receive
    end
  end
end
