require 'rails_helper'

RSpec.describe 'Api::V1::VolunteerController', type: :request do
  describe 'GET /api/v1/volunteer/profile' do
    context 'as authorized volunteer' do
      let(:volunteer) { create :volunteer, :confirmed }

      it 'returns serialized volunteer data' do
        authorized_get volunteer: volunteer,
                       path: api_v1_volunteer_profile_path
        expect(response.body).to eq VolunteerSerializer.new(volunteer).to_json
      end

      it 'returns status code 200' do
        authorized_get volunteer: volunteer,
                       path: api_v1_volunteer_profile_path
        expect(response).to have_http_status(200)
      end
    end

    context 'as unauthorized volunteer' do
      it 'returns not found error' do
        get api_v1_volunteer_profile_path
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        get api_v1_volunteer_profile_path
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'PUT /api/v1/volunteer/profile' do
    let(:volunteer) { create :volunteer, :confirmed }

    context 'as authorized volunteer' do
      it 'calls UpdateProfile service' do
        params = { first_name: 'new first name',
                   last_name: 'new last name',
                   email: 'new_email@example.com',
                   description: 'new description' }
        expect(Api::Volunteer::UpdateProfile).to receive(:new).with(volunteer, ActionController::Parameters.new(params).permit!)

        authorized_put volunteer: volunteer,
                       path: api_v1_volunteer_profile_path,
                       params: params
      end

      it 'returns status code 200' do
        authorized_put volunteer: volunteer,
                       path: api_v1_volunteer_profile_path
        expect(response).to have_http_status(200)
      end
    end

    context 'as unauthorized volunteer' do
      it 'returns not found error' do
        put api_v1_volunteer_profile_path
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        put api_v1_volunteer_profile_path
        expect(response).to have_http_status(401)
      end
    end
  end
end
