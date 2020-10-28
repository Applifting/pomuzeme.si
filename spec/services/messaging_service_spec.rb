require 'rails_helper'

describe MessagingService do
  before(:all) { I18n.locale = :cs }

  let(:message) { create :message }
  let(:outgoing_message) { MessagingService::OutgoingMessage.new message }

  describe '.create_message' do
    it 'creates Message with given args' do
      create_args = {text: 'foobar'}
      expect(Message).to receive(:create!).with(create_args).and_return(create :message)
      MessagingService.create_and_send_message create_args
    end

    it 'delivers message via background job' do
      ActiveJob::Base.queue_adapter = :test
      expect { MessagingService.create_and_send_message build(:message).attributes }
        .to have_enqueued_job(Messages::SenderJob)
    end
  end

  describe '.send_message' do
    context 'notification via SMS' do
      before { message.sms! }

      it 'sends message by SmsService' do
        expect(SmsService).to receive(:send_message)
        MessagingService.send_message message
      end

      it 'calls #message_sent callback' do
        mock_response = OpenStruct.new
        allow(SmsService).to receive(:send_message).and_yield(mock_response)
        expect(MessagingService::Callbacks).to receive(:message_sent).with(instance_of(MessagingService::OutgoingMessage), mock_response)
        MessagingService.send_message message
      end
    end

    context 'notification via Push' do
      before { message.push! }

      it 'sends message by PushService' do
        expect(PushService).to receive(:send_message)
        MessagingService.send_message message
      end

      it 'calls #message_sent callback' do
        mock_response = OpenStruct.new
        allow(PushService).to receive(:send_message).and_yield(mock_response)
        expect(MessagingService::Callbacks).to receive(:message_sent).with(instance_of(MessagingService::OutgoingMessage), mock_response)
        MessagingService.send_message message
      end
    end
  end

  describe '.callback' do
    it 'delegates callback call to common module' do
      mock_payload = OpenStruct.new
      expect(MessagingService::Callbacks).to receive(:delivery_report_received).with(mock_payload)
      MessagingService.callback :delivery_report_received, mock_payload
    end
  end
end
