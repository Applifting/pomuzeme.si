# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  context 'validations' do
    subject { create(:message) }

    it { is_expected.to validate_presence_of(:text) }
  end

  context 'associations' do
    it { should belong_to(:volunteer).optional }
    it { should belong_to(:creator).optional }
    it { should belong_to(:request).optional }
  end

  context 'enums' do
    it { should define_enum_for(:state).with_values(pending: 1, sent: 2, received: 3) }
    it { should define_enum_for(:direction).with_values(outgoing: 1, incoming: 2) }
    it { should define_enum_for(:channel).with_values(sms: 1, push: 2) }
    it { should define_enum_for(:message_type).with_values(other: 1, request_offer: 2, request_update: 3, subscriber: 4).with_prefix(:message_type) }
  end

  context 'scopes' do
    context '.unread' do
      let!(:message) { create :message, read_at: nil }

      it 'returns unreaded message' do
        expect(Message.unread).to include(message)
      end

      it 'does not return readed message' do
        message.update! read_at: DateTime.now
        expect(Message.unread).not_to include(message)
      end
    end

    context '.with_request' do
      let(:volunteer) { create :volunteer }
      let(:another_volunteer) { create :volunteer }
      let!(:request) { create :request }
      let!(:another_request) { create :request }
      let!(:message) { create :message, volunteer: volunteer }

      it 'returns messages with matching volunteer id and no request id' do
        expect(Message.with_request(request.id, volunteer.id)).to include(message)
      end

      it 'returns messages with matching volunteer id and request id' do
        message.update! request: request
        expect(Message.with_request(request.id, volunteer.id)).to include(message)
      end

      it 'does not return messages with matching volunteer id and different request id' do
        message.update! request: another_request
        expect(Message.with_request(request.id, volunteer.id)).not_to include(message)
      end

      it 'does not return messages with different volunteer id and matching request id' do
        message.update! volunteer: another_volunteer, request: request
        expect(Message.with_request(request.id, volunteer.id)).not_to include(message)
      end
    end
  end

  context '#mark_as_read' do
    let(:message) { create :message }
    let(:travel_time) { Time.zone.local(2020, 05, 05, 20, 00, 00) }

    it 'updates read_at value to current time' do
      travel_to travel_time do
        expect { message.mark_as_read }.to change { message.read_at }.from(nil).to(travel_time)
      end
    end

    it 'does not update read_at if present' do
      message.update read_at: 1.week.ago
      expect { message.mark_as_read }.not_to change { message.read_at }
    end
  end
end
