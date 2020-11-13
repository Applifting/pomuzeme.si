require 'rails_helper'
require 'support/messaging_service_helper'

RSpec.feature 'Volunteer Messages' do
  include MessagingServiceHelper

  let(:organisation) { create :organisation, :with_group }
  let(:user) { create :user, :with_organisation_group, organisation: organisation }
  let(:request) { create :request, state: :searching_capacity, organisation: organisation, text: 'Help in hospital' }
  let(:volunteer) { create :volunteer, first_name: 'Petr', last_name: 'Long', phone: '+420777111222' }
  let!(:requested_volunteer) { create :requested_volunteer, request: request, volunteer: volunteer }
  let(:incoming_message) { ->(text = ano) { MessagingService::Callbacks.message_received mock_message_response(number: volunteer.phone, text: text) } }

  before :each do
    login_as user
    incoming_message['Im not sure']
  end

  context 'when system received new new (incoming) message from requested volunteer' do
    feature 'to an opened request' do

      it 'the request list shows unread scope count' do
        visit admin_organisation_requests_path(scope: :request_unread_msgs)

        expect(page).to have_text I18n.t('active_admin.scopes.request_unread_msgs') + ' (1)'
        expect(page).to have_text 'Help in hospital'
      end
    end

    feature 'to a closed request' do
      let!(:request) { create :request, state: :closed, organisation: organisation, text: 'Help in hospital' }

      it 'the request list shows 0 unread count' do
        visit admin_organisation_requests_path

        expect(page).to have_text I18n.t('active_admin.scopes.request_unread_msgs') + ' (0)'
      end
    end

    feature 'in the request detail' do
      it 'requested volunteer has "unread messages" tag' do
        visit admin_organisation_request_path(request)

        expect(page).to have_text 'Petr Long +420777111222 veřejný seznam Odesílání zprávy nepřečtené zprávy'
      end
    end
  end

  context 'when user visits requested volunteers messages with unread messages' do
    it 'marks unread messages as read' do
      expect(requested_volunteer.reload.unread_incoming_messages_count).to eq 1

      visit new_admin_volunteer_message_path(volunteer_id: volunteer.id, request_id: request.id)

      expect(page).to have_text 'Im not sure'
      expect(requested_volunteer.reload.unread_incoming_messages_count).to eq 0
    end

    it 'recalculates unread_incoming_messages_count of all requested volunteers matched by volunteer_id' do
      group2        = create :group, name: 'Some other group'
      organisation2 = create :organisation, name: 'Some other org'
      create :organisation_group, organisation: organisation2, group: group2
      request2      = create :request, state: :searching_capacity, organisation: organisation2, text: 'Help in school'
      requested_volunteer2 = create :requested_volunteer, request: request2, volunteer: volunteer

      incoming_message['another message']

      expect(requested_volunteer.reload.unread_incoming_messages_count).to eq 2
      expect(requested_volunteer2.reload.unread_incoming_messages_count).to eq 2

      visit new_admin_volunteer_message_path(volunteer_id: volunteer.id, request_id: request.id)

      expect(requested_volunteer.reload.unread_incoming_messages_count).to eq 0
      expect(requested_volunteer2.reload.unread_incoming_messages_count).to eq 0
    end
  end
end