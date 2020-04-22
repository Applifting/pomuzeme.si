require 'rails_helper'

RSpec.describe 'Api::V1::Volunteer::RequestsController', type: :request do
  describe 'GET /api/v1/volunteer/requests' do
    context 'as authorized volunteer' do
      let(:volunteer) { create :volunteer }

      context 'when volunteer should not see requests' do
        let!(:requested_volunteer_pending) { create :requested_volunteer, volunteer: volunteer, state: :to_be_notified }
        let!(:requested_volunteer_pending) { create :requested_volunteer, volunteer: volunteer, state: :pending_notification }
        let!(:requested_volunteer_pending) { create :requested_volunteer, volunteer: volunteer, state: :removed }

        it 'is not returned in response' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_requests_path
          expect(response.body).to eq [].to_json
        end

        it 'returns status code 200' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_requests_path
          expect(response).to have_http_status(200)
        end
      end

      context 'when volunteer should see requests' do
        let!(:requested_volunteer_notified) { create :requested_volunteer, volunteer: volunteer, state: :notified }
        let!(:requested_volunteer_accepted) { create :requested_volunteer, volunteer: volunteer, state: :accepted }
        let!(:requested_volunteer_rejected) { create :requested_volunteer, volunteer: volunteer, state: :rejected }

        it 'is not returned in response' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_requests_path
          expect(response.body).to eq [RequestedVolunteerSerializer.new(requested_volunteer_notified),
                                       RequestedVolunteerSerializer.new(requested_volunteer_accepted),
                                       RequestedVolunteerSerializer.new(requested_volunteer_rejected)].to_json
        end

        it 'returns status code 200' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_requests_path
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'as unauthorized volunteer' do
      it 'returns not found error' do
        get api_v1_volunteer_organisations_path
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        get api_v1_volunteer_organisations_path
        expect(response).to have_http_status(401)
      end
    end
  end
end
