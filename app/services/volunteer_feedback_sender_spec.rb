require 'rails_helper'

describe VolunteerFeedback::Sender do
  describe '.call' do
    let(:organisation)        { create :organisation, volunteer_feedback_message: 'Feedback form for %{prijimajici_organizace}',
                                                      volunteer_feedback_send_after_days: 1 }
    let(:request)             { create :request, organisation: organisation, subscriber: 'the girl' }
    let(:requested_volunteer) { create :requested_volunteer, request: request }

    before :each do
      travel_to 2.days.ago do
        requested_volunteer.accepted!
      end
    end

    it 'creates feedback request message with relevant attributes' do
      expect(Message.count).to eq 0

      VolunteerFeedback::Sender.call requested_volunteer

      expect(Message.count).to eq 1
      expect(Message.first).to have_attributes channel: 'sms',
                                               direction: 'outgoing',
                                               message_type: 'feedback_request',
                                               volunteer_id: requested_volunteer.volunteer_id,
                                               request_id: requested_volunteer.request_id,
                                               phone: requested_volunteer.phone,
                                               read_at: nil,
                                               text: 'Feedback form for the girl'

    end

    it 'creates RequestedVolunteerFeedback record to prevent multiple sending of feedback request' do
      expect(requested_volunteer.feedback_request).to be_blank

      VolunteerFeedback::Sender.call requested_volunteer

      expect(requested_volunteer.reload.feedback_request).to be_present
    end

    context 'when transaction fails' do
      before :each do
        allow(RequestedVolunteerFeedback).to receive(:create!).and_raise(ActiveRecord::Rollback)
        ActiveJob::Base.queue_adapter = :test
      end

      it 'does not save the message' do
        expect { VolunteerFeedback::Sender.call requested_volunteer }.to change { Message.count }.by(0)
      end

      it 'does not send the feedback request message' do
        expect { VolunteerFeedback::Sender.call requested_volunteer }.to change { RequestedVolunteerFeedback.count }.by(0)
      end

      it 'does not send the message' do
        expect(Messages::SenderJob).not_to receive(:perform_later)

        VolunteerFeedback::Sender.call requested_volunteer
      end
    end

    context 'when transaction succeeds' do
      before :each do
        ActiveJob::Base.queue_adapter = :test
      end

      it 'sends the feedback request message' do
        expect { VolunteerFeedback::Sender.call requested_volunteer }.to have_enqueued_job(Messages::SenderJob)
      end
    end
  end
end