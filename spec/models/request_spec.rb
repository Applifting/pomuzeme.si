# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Request, type: :model do
  context 'validations' do
    subject { build(:request) }

    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_length_of(:text).is_at_most(160) }
    it { is_expected.to validate_presence_of(:required_volunteer_count) }
    it { is_expected.to validate_presence_of(:subscriber) }
    it { is_expected.to validate_length_of(:subscriber).is_at_most(150) }
    it { is_expected.to validate_presence_of(:subscriber_phone) }
    it { is_expected.to validate_presence_of(:creator) }
    it { is_expected.to validate_length_of(:closed_note).is_at_most(500) }

    it { is_expected.not_to allow_values('foo', '1 b@example.c').for(:subscriber_email) }
    it { is_expected.to allow_values('test@example.com').for(:subscriber_email) }
    it { is_expected.not_to allow_values('+420 abc 111 111').for(:subscriber_phone) }
    it { is_expected.to allow_values('+420444444444', '+420 444 444 444').for(:subscriber_phone) }
  end

  context 'associations' do
    it { should have_many(:requested_volunteers) }
    it { should have_many(:volunteers) }
    it { should have_many(:messages) }
    it { should have_one(:address) }
    it { should belong_to(:closer).class_name('User').optional }
    it { should belong_to(:coordinator).class_name('User').optional }
  end

  context 'enums' do
    it { should define_enum_for(:state).with_values(created: 1, searching_capacity: 2, pending_confirmation: 3, help_coordinated: 4, closed: 5) }
    it { should define_enum_for(:closed_state).with_values(fulfilled: 1, failed: 2, irrelevant: 3) }
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

    context '.assignable' do
      let(:request) { create :request }

      it 'returns requests with state created' do
        request.created!
        expect(Request.assignable).to include request
      end

      it 'returns requests with state searching_capacity' do
        request.searching_capacity!
        expect(Request.assignable).to include request
      end

      it 'returns requests with state pending_confirmation' do
        request.pending_confirmation!
        expect(Request.assignable).to include request
      end

      it 'does not return requests with state help_coordinated' do
        request.help_coordinated!
        expect(Request.assignable).not_to include request
      end

      it 'does not return requests with state closed' do
        request.closed!
        expect(Request.assignable).not_to include request
      end
    end

    context '.with_organisations' do
      let(:organisation) { create :organisation }
      let(:foreign_organisation) { create :organisation }
      let!(:request) { create :request, organisation: organisation }
      let!(:foreign_request) { create :request, organisation: foreign_organisation }

      it 'returns requests for given organisation' do
        expect(Request.with_organisations([organisation.id])).to include(request)
      end

      it 'does not return requests for foreign organisation' do
        expect(Request.with_organisations([organisation.id])).not_to include(foreign_request)
      end
    end

    context '.in_progress' do
      skip 'figure out if written scope is relevant for us'
    end

    context '.for_followup' do
      let!(:request) { create :request, fullfillment_date: 1.week.ago, state: :help_coordinated }

      it 'returns coordinated requests with fullfillment date not exceeded' do
        expect(Request.for_followup).to include request
      end

      it 'does not return coordinated requests with fullfillment date exceeded' do
        request.update! fullfillment_date: 1.week.from_now
        expect(Request.for_followup).not_to include request
      end

      it 'does not return requests with fullfillment date not exceeded, but different state' do
        request.update! fullfillment_date: 1.week.from_now, state: :created
        expect(Request.for_followup).not_to include request
      end

      it 'does not return coordinated requests with nil fullfillment date' do
        request.update! fullfillment_date: nil
        expect(Request.for_followup).not_to include request
      end
    end

    context '.without_coordinator' do
      let!(:request_with_coordinator) { create :request, coordinator: create(:user) }
      let!(:request_without_coordinator) { create :request, coordinator: nil }

      it 'returns request without assigned coordinator' do
        expect(Request.without_coordinator).to include request_without_coordinator
      end

      it 'does not return request with assigned coordinator' do
        expect(Request.without_coordinator).not_to include request_with_coordinator
      end
    end

    context '.has_unread_messages' do
      let(:request) { create :request }
      let(:requested_volunteer) { create :requested_volunteer, request: request }
      let(:volunteer) { requested_volunteer.volunteer }

      it 'returns requests having unreaded incoming message' do
        create :message, :incoming, request: request, read_at: nil, volunteer: volunteer
        expect(Request.has_unread_messages).to include request
      end

      it 'does not return requests having all incoming message read' do
        create :message, :incoming, request: request, read_at: Time.current, volunteer: volunteer
        expect(Request.has_unread_messages).not_to include request
      end

      it 'does not return requests unreaded incoming message, but not matched via volunteer' do
        create :message, :incoming, request: request, read_at: Time.current
        expect(Request.has_unread_messages).not_to include request
      end

      it 'does not return requests having unreaded outgoing message' do
        create :message, :outgoing, request: request, read_at: nil, volunteer: volunteer
        expect(Request.has_unread_messages).not_to include request
      end
    end
  end

  describe 'Validation hooks' do
    it 'creates a new record with created state if not specified' do
      expect(create(:request, state: nil)).to be_created
    end


    describe '#state_last_updated_at' do
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

      context 'when record is created' do
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

      context 'when record is updated' do
        let(:request) { create(:request) }

        it 'does not change the value if state was not changed' do
          expect { request.update(text: 'new text' ) }.not_to change { request.state_last_updated_at }
        end

        it 'does changes the value if state was changed' do
          expect { request.update(state: :closed ) }.to change { request.state_last_updated_at }
        end
      end
    end
  end

  context '#identifier' do
    let(:request) { create :request }

    it 'is made of organisations abbreviation and id' do
      expect(request.identifier).to eq([request.organisation.abbreviation, ('%04d' % request.id)].join '-')
    end
  end
end
