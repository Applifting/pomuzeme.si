require 'rails_helper'

RSpec.describe 'Api::V1::OrganisationsController', type: :request do
  describe 'GET /api/v1/organisations' do
    context 'as authorized volunteer' do
      let(:volunteer) { create :volunteer, :confirmed }
      let!(:organisation_1) { create :organisation }
      let!(:organisation_2) { create :organisation }

      it 'returns serialized organisations' do
        authorized_get volunteer: volunteer,
                       path: api_v1_organisations_path
        parsed_response = JSON.parse response.body
        expect(parsed_response).to eq [OrganisationSerializer.new(organisation_1).as_json.stringify_keys,
                                       OrganisationSerializer.new(organisation_2).as_json.stringify_keys]
      end

      it 'returns status code 200' do
        authorized_get volunteer: volunteer,
                       path: api_v1_organisations_path
        expect(response).to have_http_status(200)
      end
    end

    context 'as unauthorized volunteer' do
      it 'returns not found error' do
        get api_v1_organisations_path
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        get api_v1_organisations_path
        expect(response).to have_http_status(401)
      end
    end
  end
end
