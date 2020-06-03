require 'rails_helper'
require 'support/messaging_service_helper'

describe MessagingService::Callbacks do
  include MessagingServiceHelper

  before(:all) { I18n.locale = :cs }
  let(:requested_volunteer) { create :requested_volunteer }
  let(:volunteer) { requested_volunteer.volunteer }
  let(:request) { requested_volunteer.request }
  let(:message) { create :message, :request_offer, request: request, volunteer: volunteer }
  let(:message_object) { MessagingService::OutgoingMessage.new message }

  describe '.message_sent' do
    it 'changes message status to sent' do
      message_response = mock_message_response

      expect { MessagingService::Callbacks.message_sent(message_object, message_response) }
        .to change { message.reload.state }.from('pending').to('sent')
    end

    it 'updates message channel id from response data' do
      message_response = mock_message_response message_id: '12345'

      expect { MessagingService::Callbacks.message_sent(message_object, message_response) }
        .to change { message.reload.channel_msg_id }.from(nil).to('12345')
    end

    it 'marks requested volunteer as notified is message is request offer type' do
      message_response = mock_message_response message_id: '12345'

      expect(message.message_type_request_offer?).to be true
      expect { MessagingService::Callbacks.message_sent(message_object, message_response) }
        .to change { requested_volunteer.reload.state }.from('pending_notification').to('notified')
    end

    it 'does not change requested volunteer state if message is not request offer type' do
      message_response = mock_message_response message_id: '12345'

      message.message_type_other!
      expect(message.message_type_request_offer?).to be false
      expect { MessagingService::Callbacks.message_sent(message_object, message_response) }
        .not_to change { requested_volunteer.reload.state }
    end
  end

  describe '.delivery_report_received' do
    it 'does nothing when message is not found' do
      message_response = mock_message_response

      expect_any_instance_of(Message).not_to receive(:update)
      MessagingService::Callbacks.delivery_report_received message_response
    end

    it 'marks message as read' do
      message_response = mock_message_response message_id: '42'

      message.update channel_msg_id: '42', state: 'sent'
      expect { MessagingService::Callbacks.delivery_report_received message_response }
        .to change { message.reload.state }.from('sent').to('received')
    end

    it 'stores delivery timestamp from report to message' do
      delivery_time = 1.hour.ago
      message_response = mock_message_response message_id: '42', timestamp: delivery_time

      message.update channel_msg_id: '42', state: 'sent'
      expect { MessagingService::Callbacks.delivery_report_received message_response }
        .to change { message.reload.read_at&.iso8601 }.from(nil).to(delivery_time.iso8601) # use iso8601 to resolve DB rounding of miliseconds
    end
  end

  describe '.message_received' do
    before { message.incoming! }

    it 'does nothing when volunteer is not recognized from message' do
      message_response = mock_message_response number: nil

      expect(Message).not_to receive(:create!)
      MessagingService::Callbacks.message_received message_response
    end

    it 'creates incoming message from volunteer' do
      message_response = mock_message_response number: volunteer.phone, text: 'hello world'

      expect(Message).to receive(:create!).with(volunteer: volunteer,
                                                text: 'hello world',
                                                direction: :incoming,
                                                state: :received,
                                                channel: :sms)

      MessagingService::Callbacks.message_received message_response
    end

    it 'schedules job processing incoming message' do
      message_response = mock_message_response number: volunteer.phone

      ActiveJob::Base.queue_adapter = :test
      expect { MessagingService::Callbacks.message_received message_response }
        .to have_enqueued_job(Messages::ReceivedProcessorJob)
    end
  end
end
