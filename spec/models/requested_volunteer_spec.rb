# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestedVolunteer, type: :model do
  describe 'associations' do
    it { should belong_to(:request) }
    it { should belong_to(:volunteer) }
    it { should have_many(:messages) }
    it { should have_one(:feedback_request) }
  end

  describe 'scopes' do
    describe '#without_feedback_request' do
      let(:requested_volunteer_with)    { create :requested_volunteer }
      let(:requested_volunteer_without) { create :requested_volunteer }

      before do
        RequestedVolunteerFeedback.create! requested_volunteer: requested_volunteer_with
      end

      it 'lists requested_volunteers who do not yet have a feedback request record' do
        expect(RequestedVolunteer.without_feedback_request).to include requested_volunteer_without
        expect(RequestedVolunteer.without_feedback_request).not_to include requested_volunteer_with
      end
    end

    describe 'feedback scopes' do
      let(:organisation)            { create :organisation, volunteer_feedback_message: 'Hi!', volunteer_feedback_send_after_days: 10 }
      let(:request)                 { create :request, organisation: organisation }
      let(:requested_volunteer_in)  { create :requested_volunteer, request: request }
      let(:requested_volunteer_out1) { create :requested_volunteer, request: request }
      let(:requested_volunteer_out2) { create :requested_volunteer, request: request }
      let(:requested_volunteer_out3) { create :requested_volunteer, :accepted }

      before :each do
        travel_to 11.days.ago do
          requested_volunteer_in.accepted!
          requested_volunteer_out3.accepted!
        end
        requested_volunteer_out1.accepted!
        requested_volunteer_out2.rejected!
      end

      it '#feedback_time lists requested_volunteers who accepted a request before time configured by organisations.volunteer_feedback_send_after_days' do
        expect(RequestedVolunteer.feedback_required.count).to eq 1
        expect(RequestedVolunteer.feedback_time).to include requested_volunteer_in
        expect(RequestedVolunteer.feedback_time).not_to include requested_volunteer_out1
        expect(RequestedVolunteer.feedback_time).not_to include requested_volunteer_out2
      end

      it '#feedback_required lists requested_volunteers without feedback who accepted a request before time configured by organisations.volunteer_feedback_send_after_days' do
        RequestedVolunteerFeedback.create! requested_volunteer: requested_volunteer_out1

        expect(RequestedVolunteer.feedback_required.count).to eq 1
        expect(RequestedVolunteer.feedback_required).to include requested_volunteer_in
        expect(RequestedVolunteer.feedback_required).not_to include requested_volunteer_out1
        expect(RequestedVolunteer.feedback_required).not_to include requested_volunteer_out2

        # requested_volunteer_out3 is left out because his request's organisation does not have the feedback attributes setup
        expect(RequestedVolunteer.feedback_required).not_to include requested_volunteer_out3
      end
    end
  end
end
