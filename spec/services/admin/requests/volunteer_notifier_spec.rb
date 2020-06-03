require 'rails_helper'

describe Admin::Requests::VolunteerNotifier do
  let(:request) { create :request }
  let(:user) { request.creator }
  let(:requested_volunteer) { create :requested_volunteer, request: request }
  let(:volunteer) { requested_volunteer.volunteer }

  before(:all) { I18n.locale = :cs }

  describe '#notify_assigned' do
    before(:each) { requested_volunteer.to_be_notified! }

    it 'notifies assigned users via push if fcm is present and notifications are active' do
      allow_any_instance_of(Volunteer).to receive(:fcm_active?).and_return(true)
      allow_any_instance_of(Volunteer).to receive(:push_notifications?).and_return(true)
      expect(MessagingService).to receive(:create_message).with(direction: :outgoing,
                                                                message_type: :request_offer,
                                                                request: request,
                                                                channel: :push,
                                                                text: I18n.t('push.notifications.request.new.body',
                                                                             description: request.text,
                                                                             organisation: request.organisation.name),
                                                                volunteer_id: volunteer.id,
                                                                creator: user)
      Admin::Requests::VolunteerNotifier.new(user, request).notify_assigned
    end

    it 'does not notify assigned users via push if fcm is present and notifications are disabled' do
      allow_any_instance_of(Volunteer).to receive(:fcm_active?).and_return(true)
      allow_any_instance_of(Volunteer).to receive(:push_notifications?).and_return(false)
      expect(MessagingService).to receive(:create_message).with(direction: :outgoing,
                                                                message_type: :request_offer,
                                                                request: request,
                                                                channel: :sms,
                                                                text: I18n.t('sms.request.offer',
                                                                             identifier: request.identifier,
                                                                             text: request.text),
                                                                volunteer_id: volunteer.id,
                                                                creator: user)
      Admin::Requests::VolunteerNotifier.new(user, request).notify_assigned
    end

    it 'notifies assigned users via sms if fcm is not present' do
      allow_any_instance_of(Volunteer).to receive(:fcm_active?).and_return(false)
      allow_any_instance_of(Volunteer).to receive(:push_notifications?).and_return(false)
      expect(MessagingService).to receive(:create_message).with(direction: :outgoing,
                                                                message_type: :request_offer,
                                                                request: request,
                                                                channel: :sms,
                                                                text: I18n.t('sms.request.offer',
                                                                             identifier: request.identifier,
                                                                             text: request.text),
                                                                volunteer_id: volunteer.id,
                                                                creator: user)
      Admin::Requests::VolunteerNotifier.new(user, request).notify_assigned
    end

    it 'changes RequestedVolunteer state to pending_notification' do
      expect { Admin::Requests::VolunteerNotifier.new(user, request).notify_assigned }
        .to change { requested_volunteer.reload.state }.from('to_be_notified').to('pending_notification')
    end
  end

  describe '#notify_updated' do
    before(:each) { requested_volunteer.notified! }

    it 'notifies assigned users via push if fcm is present and notifications are active' do
      allow_any_instance_of(Volunteer).to receive(:fcm_active?).and_return(true)
      allow_any_instance_of(Volunteer).to receive(:push_notifications?).and_return(true)
      expect(MessagingService).to receive(:create_message).with(direction: :outgoing,
                                                                message_type: :request_update,
                                                                request: request,
                                                                channel: :push,
                                                                text: I18n.t('push.notifications.request.update.body',
                                                                             description: request.text,
                                                                             organisation: request.organisation.name),
                                                                volunteer_id: volunteer.id,
                                                                creator: user)
      Admin::Requests::VolunteerNotifier.new(user, request).notify_updated
    end

    it 'does not notify assigned users via push if volunteer rejected offer' do
      requested_volunteer.rejected!
      allow_any_instance_of(Volunteer).to receive(:fcm_active?).and_return(true)
      allow_any_instance_of(Volunteer).to receive(:push_notifications?).and_return(true)
      expect(MessagingService).not_to receive(:create_message)

      Admin::Requests::VolunteerNotifier.new(user, request).notify_updated
    end

    it 'does not notify assigned users via push if fcm is present and notifications are disabled' do
      allow_any_instance_of(Volunteer).to receive(:fcm_active?).and_return(true)
      allow_any_instance_of(Volunteer).to receive(:push_notifications?).and_return(false)
      expect(MessagingService).not_to receive(:create_message)

      Admin::Requests::VolunteerNotifier.new(user, request).notify_updated
    end

    it 'does not notify assigned users via sms if fcm is not present' do
      allow_any_instance_of(Volunteer).to receive(:fcm_active?).and_return(false)
      allow_any_instance_of(Volunteer).to receive(:push_notifications?).and_return(false)
      expect(MessagingService).not_to receive(:create_message)

      Admin::Requests::VolunteerNotifier.new(user, request).notify_updated
    end

    it 'does not change state of RequestedVolunteer' do
      expect { Admin::Requests::VolunteerNotifier.new(user, request).notify_updated }
        .not_to change { requested_volunteer.reload.state }
    end
  end
end
