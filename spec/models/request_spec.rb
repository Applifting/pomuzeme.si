# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Request, type: :model do
  context 'validations' do
    subject { build(:request) }

    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_presence_of(:required_volunteer_count) }
    it { is_expected.to validate_presence_of(:subscriber) }
    it { is_expected.to validate_presence_of(:subscriber_phone) }
    it { is_expected.to validate_presence_of(:creator) }

    it { is_expected.not_to allow_values('444 444 444', '+420 abc 111 111').for(:subscriber_phone) }
    it { is_expected.to allow_values('+420444444444', '+420 444 444 444').for(:subscriber_phone) }
  end

  context 'associations' do
    it { should belong_to(:creator).class_name('User') }
    it { should belong_to(:organisation) }
  end

  context 'Reccord creation' do
    it 'creates a new record with created state if not specified' do
      expect(create(:request, state: nil)).to be_created
    end
  end

  context '#state_last_updated_at' do
    let(:params) do
      {
        organisation: build(:organisation),
        text: 'Request for 5 volunteers',
        required_volunteer_count: 5,
        subscriber: 'Subscriber',
        subscriber_phone: '+420 555 555 555',
        creator: build(:user),
        state: :created,
      }
    end
    let(:travel_time) { Time.zone.local(2020, 05, 05, 20, 00, 00) }

    context 'during creation' do
      before do
        travel_to travel_time
      end

      after do
        travel_back
      end

      subject { described_class.create(params) }

      it 'sets the value as provided in the params' do
        params[:state_last_updated_at] = travel_time.iso8601

        expect(subject.state_last_updated_at).to eq(travel_time)
      end

      it 'sets the value to now if not provided in the params' do
        expect(subject.state_last_updated_at).to eq(travel_time)
      end
    end

    context 'during update' do
      let(:request) { create(:request) }

      it 'does not change the value if state was not changed' do
        expect { request.update(text: 'new text' ) }.not_to change { request.state_last_updated_at }
      end

      it 'does changes the value if state was changed' do
        expect { request.update(state: :closed ) }.to change { request.state_last_updated_at }
      end
    end
  end

  context 'scopes' do
    context '.sorted_state' do
      it 'returns all requests sorted by state and state_last_updated_at' do
        request1 = create(:request, state: :created, state_last_updated_at: '2020-01-01')
        request2 = create(:request, state: :pending_confirmation)
        request3 = create(:request, state: :created, state_last_updated_at: '2020-03-01')

        expect(Request.sorted_state).to eq([request3, request1, request2])
      end
    end
  end
end
