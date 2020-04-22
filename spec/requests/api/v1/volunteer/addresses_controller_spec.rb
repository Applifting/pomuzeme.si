require 'rails_helper'
require 'support/geocoder_helper'

RSpec.describe 'Api::V1::Volunteer::AddressesController', type: :request do
  include GeocoderHelper

  let(:volunteer) { create :volunteer }
  let(:another_volunteer) { create :volunteer }
  let(:volunteer_address) { volunteer.addresses.first }
  let(:another_volunteer_address) { another_volunteer.addresses.first }

  describe 'GET /api/v1/volunteer/addresses' do
    context 'as authorized volunteer' do
      it 'returns all addresses belonging to volunteer' do
        authorized_get volunteer: volunteer,
                       path: api_v1_volunteer_addresses_path
        expect(response.body).to eq volunteer.addresses.map { |address| AddressSerializer.new address }.to_json
      end

      it 'returns status code 200' do
        authorized_get volunteer: volunteer,
                       path: api_v1_volunteer_addresses_path
        expect(response).to have_http_status(200)
      end
    end

    context 'as unauthorized volunteer' do
      it 'returns unauthorized error' do
        get api_v1_volunteer_addresses_path
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        get api_v1_volunteer_addresses_path
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'GET /api/v1/volunteer/address' do
    context 'as authorized volunteer' do
      context 'when reading own address' do
        it 'returns requested address' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_address_path(volunteer_address)
          expect(response.body).to eq AddressSerializer.new(volunteer_address).to_json
        end

        it 'returns status code 200' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_address_path(volunteer_address)
          expect(response).to have_http_status(200)
        end
      end

      context 'when reading foreign address' do
        it 'returns unauthorized error' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_address_path(another_volunteer_address)
          expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_address_path(another_volunteer_address)
          expect(response).to have_http_status(401)
        end
      end

      context 'when reading non existing address' do
        it 'returns unauthorized error' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_address_path(Address.last.id + 1)
          expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          authorized_get volunteer: volunteer,
                         path: api_v1_volunteer_address_path(Address.last.id + 1)
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'as unauthorized volunteer' do
      it 'returns unauthorized error' do
        get api_v1_volunteer_address_path(another_volunteer_address)
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        get api_v1_volunteer_address_path(another_volunteer_address)
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'POST /api/v1/volunteer/address' do
    let(:params) { { place_id: 42, default: false } }
    context 'as authorized volunteer' do
      context 'all data are provided' do
        before { mock_geocoder_search }

        it 'new address is created' do
          expect do
            authorized_post volunteer: volunteer,
                            path: api_v1_volunteer_addresses_path,
                            params: params
          end.to change { volunteer.addresses.reload.count }.by(1)
        end

        it 'return new address' do
          authorized_post volunteer: volunteer,
                          path: api_v1_volunteer_addresses_path,
                          params: params
          expect(response.body).to eq AddressSerializer.new(volunteer.addresses.reload.last).to_json
        end

        it 'returns status code 201' do
          authorized_post volunteer: volunteer,
                          path: api_v1_volunteer_addresses_path,
                          params: params
          expect(response).to have_http_status(201)
        end
      end

      context 'all data are provided, but place id is invalid' do
        before { allow(Geocoder).to receive(:search).with(any_args).and_return([]) }

        it 'returns address invalid error' do
          authorized_post volunteer: volunteer,
                          path: api_v1_volunteer_addresses_path,
                          params: params
          expect(response.body).to include_json(error_key: 'ADDRESS_INVALID')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          authorized_post volunteer: volunteer,
                          path: api_v1_volunteer_addresses_path,
                          params: params
          expect(response).to have_http_status(401)
        end
      end

      context 'place_id is missing' do

        it 'returns address invalid error' do
          authorized_post volunteer: volunteer,
                          path: api_v1_volunteer_addresses_path
          expect(response.body).to include_json(error_key: 'ADDRESS_INVALID')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          authorized_post volunteer: volunteer,
                          path: api_v1_volunteer_addresses_path
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'as unauthorized volunteer' do
      let(:request) { create :request }
      it 'returns not found error' do
        post api_v1_volunteer_requests_respond_path(request)
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        post api_v1_volunteer_requests_respond_path(request)
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'PUT /api/v1/volunteer/address' do
    context 'as authorized volunteer' do
      let(:params) { { default: 'true' } }

      context 'when updating own address with valid data' do
        before do
          volunteer_address.update! default: false
          mock_geocoder_search
        end

        it 'updates given address' do
          expect do
            authorized_put volunteer: volunteer,
                           path: api_v1_volunteer_address_path(volunteer_address),
                           params: params
          end.to change { volunteer_address.reload.default? }.from(false).to(true)
        end

        it 'returns status code 202' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_address_path(volunteer_address),
                         params: params
          expect(response).to have_http_status(202)
        end
      end

      context 'when updating own address with invalid data' do
        it 'returns address invalid error' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_address_path(volunteer_address),
                         params: params
          expect(response.body).to include_json(error_key: 'ADDRESS_INVALID')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_address_path(volunteer_address),
                         params: params
          expect(response).to have_http_status(401)
        end
      end

      context 'when updating foreign address' do
        it 'returns unauthorized error' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_address_path(another_volunteer_address),
                         params: params
          expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_address_path(another_volunteer_address),
                         params: params
          expect(response).to have_http_status(401)
        end
      end

      context 'when updating non existing address' do
        it 'returns unauthorized error' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_address_path(Address.last.id + 1),
                         params: params
          expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_address_path(Address.last.id + 1),
                         params: params
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'as unauthorized volunteer' do
      let(:request) { create :request }
      it 'returns not found error' do
        post api_v1_volunteer_requests_respond_path(request)
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        post api_v1_volunteer_requests_respond_path(request)
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'DELETE /api/v1/volunteer/address' do
    context 'as authorized volunteer' do
      context 'when destroying own address' do
        it 'destroys given address' do
          expect do
            authorized_delete volunteer: volunteer,
                           path: api_v1_volunteer_address_path(volunteer_address)
          end.to change { Address.where(id: volunteer_address).any? }.from(true).to(false)
        end

        it 'returns status code 200' do
          authorized_delete volunteer: volunteer,
                            path: api_v1_volunteer_address_path(volunteer_address)
          expect(response).to have_http_status(200)
        end
      end

      context 'when destroying foreign address' do
        it 'returns unauthorized error' do
          authorized_delete volunteer: volunteer,
                            path: api_v1_volunteer_address_path(another_volunteer_address)
          expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          authorized_delete volunteer: volunteer,
                            path: api_v1_volunteer_address_path(another_volunteer_address)
          expect(response).to have_http_status(401)
        end
      end

      context 'when destroying non existing address' do
        it 'returns unauthorized error' do
          authorized_delete volunteer: volunteer,
                            path: api_v1_volunteer_address_path(Address.last.id + 1)
          expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          authorized_delete volunteer: volunteer,
                            path: api_v1_volunteer_address_path(Address.last.id + 1)
          expect(response).to have_http_status(401)
        end
      end
    end

    context 'as unauthorized volunteer' do
      let(:request) { create :request }
      it 'returns not found error' do
        post api_v1_volunteer_requests_respond_path(request)
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        post api_v1_volunteer_requests_respond_path(request)
        expect(response).to have_http_status(401)
      end
    end
  end
end
