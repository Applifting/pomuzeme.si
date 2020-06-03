require 'rails_helper'

describe Admin::Requests::VolunteerAssigner do
  before(:all) { I18n.locale = :cs }

  describe '#perform' do
    let(:volunteer) { create :volunteer }
    let(:user) { create :user }
    let(:request) { create :request }
    let(:organisation_group) { create :organisation_group }

    before do
      allow_any_instance_of(User).to receive(:organisation_group).and_return(organisation_group)
    end

    it 'assigns volunteers with given state' do
      state = 'accepted'
      Admin::Requests::VolunteerAssigner.new(user, request, Volunteer.where(id: volunteer.id), requested_state: state).perform
      requested_volunteer = RequestedVolunteer.last
      expect(requested_volunteer.volunteer).to eq volunteer
      expect(requested_volunteer.request).to eq request
      expect(requested_volunteer.state).to eq state
    end

    it 'assigns volunteers with default state' do
      Admin::Requests::VolunteerAssigner.new(user, request, Volunteer.where(id: volunteer.id)).perform
      requested_volunteer = RequestedVolunteer.last
      expect(requested_volunteer.volunteer).to eq volunteer
      expect(requested_volunteer.request).to eq request
      expect(requested_volunteer.state).to eq Admin::Requests::VolunteerAssigner::DEFAULT_STATE
    end

    it 'does not assign volunteers when not availavle' do
      allow(Volunteer).to receive(:available_for).and_return(Volunteer.none)
      Admin::Requests::VolunteerAssigner.new(user, request, Volunteer.where(id: volunteer.id)).perform
      expect(RequestedVolunteer.all).to be_empty
    end
  end
end
