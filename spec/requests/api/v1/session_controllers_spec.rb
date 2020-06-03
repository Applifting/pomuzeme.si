require 'rails_helper'

RSpec.describe 'Api::V1::SessionControllers', type: :request do
  describe 'POST /api/v1/session/new' do
    context 'with registered volunteer number' do
      let(:volunteer) { create :volunteer, :confirmed }

      it 'sends authorization code to volunteer' do
        expect_any_instance_of(Volunteer).to receive(:obtain_authorization_code)
        post api_v1_session_new_path, params: { phone_number: volunteer.phone }
      end

      it 'returns status code 200' do
        allow_any_instance_of(Volunteer).to receive(:obtain_authorization_code)
        post api_v1_session_new_path, params: { phone_number: volunteer.phone }
        expect(response).to have_http_status(200)
      end

      it 'updates volunteers fcm token if token is present' do
        allow_any_instance_of(Volunteer).to receive(:obtain_authorization_code)
        expect { post api_v1_session_new_path, params: { phone_number: volunteer.phone, fcm_token: 'uniq_token' } }
            .to change { volunteer.reload.fcm_token }.from(nil).to('uniq_token')
      end

      it 'validates recaptcha challenge' do
        skip 'implement when recaptcha is activated'
      end
    end

    context 'with unregistered number' do
      it 'returns not found error' do
        post api_v1_session_new_path, params: { phone_number: '+420111222333' }
        expect(response.body).to include_json(error_key: 'VOLUNTEER_NOT_FOUND')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 404' do
        post api_v1_session_new_path, params: { phone_number: '+420111222333' }
        expect(response).to have_http_status(404)
      end
    end

    context 'with unconfirmed volunteer number' do
      let(:volunteer) { create :volunteer, :unconfirmed }

      it 'returns not found error' do
        post api_v1_session_new_path, params: { phone_number: volunteer.phone }
        expect(response.body).to include_json(error_key: 'VOLUNTEER_NOT_FOUND')
        expect(response.body).to include_json(message: nil)
      end
    end
  end

  describe 'POST /api/v1/session/create' do
    context 'with registered volunteer number' do
      let(:volunteer) { create :volunteer, :confirmed, :initialized_authorization }

      context 'and with invalid authorization code' do
        it 'returns unauthorized error' do
          post api_v1_session_create_path, params: { phone_number: volunteer.phone, sms_verification_code: volunteer.authorization_code[0..-2] }
          expect(response.body).to include_json(error_key: 'INVALID_VERIFICATION_CODE')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          post api_v1_session_create_path, params: { phone_number: volunteer.phone, sms_verification_code: volunteer.authorization_code[0..-2] }
          expect(response).to have_http_status(401)
        end
      end

      context 'and with invalid authorization code exceeding attempts limit' do
        before { volunteer.update! authorization_code_attempts: 1 }

        it 'returns unauthorized error' do
          post api_v1_session_create_path, params: { phone_number: volunteer.phone, sms_verification_code: volunteer.authorization_code[0..-2] }
          expect(response.body).to include_json(error_key: 'INVALID_VERIFICATION_CODE')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 429 - too many requests' do
          post api_v1_session_create_path, params: { phone_number: volunteer.phone, sms_verification_code: volunteer.authorization_code[0..-2] }
          expect(response).to have_http_status(429)
        end
      end

      context 'and with valid expired authorization code' do
        before { volunteer.update! authorization_code_valid_to: 1.minute.ago }

        it 'returns unauthorized error' do
          post api_v1_session_create_path, params: { phone_number: volunteer.phone, sms_verification_code: volunteer.authorization_code }
          expect(response.body).to include_json(error_key: 'INVALID_VERIFICATION_CODE')
          expect(response.body).to include_json(message: nil)
        end

        it 'returns status code 401' do
          post api_v1_session_create_path, params: { phone_number: volunteer.phone, sms_verification_code: volunteer.authorization_code }
          expect(response).to have_http_status(401)
        end
      end

      context 'with valid authorization code' do
        it 'returns authorization token with encoded volunteer' do
          expect(Api::JsonWebToken).to receive(:encode).and_return('TOKEN')
          post api_v1_session_create_path, params: { phone_number: volunteer.phone, sms_verification_code: volunteer.authorization_code }
          expect(response.body).to include_json(token: 'TOKEN')
        end

        it 'returns status code 200' do
          post api_v1_session_create_path, params: { phone_number: volunteer.phone, sms_verification_code: volunteer.authorization_code }
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'with unregistered number' do
      let(:volunteer) { create :volunteer, :unconfirmed }

      it 'returns not found error' do
        post api_v1_session_create_path, params: { phone_number: '+420111222333', code: '3242' }
        expect(response.body).to include_json(error_key: 'VOLUNTEER_NOT_FOUND')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 404' do
        post api_v1_session_new_path, params: { phone_number: '+420111222333', code: '3242' }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/session/refresh' do
    context 'as authorized volunteer' do
      let(:volunteer) { create :volunteer, :confirmed }

      it 'returns refreshed user token' do
        authorized_post volunteer: volunteer,
                        path: api_v1_session_refresh_path
        expect(JSON.parse(response.body)).to have_key('token')
      end

      it 'returns status code 200' do
        authorized_post volunteer: volunteer,
                        path: api_v1_session_refresh_path
        expect(response).to have_http_status(200)
      end
    end

    context 'as unauthorized volunteer' do
      it 'returns not found error' do
        post api_v1_session_refresh_path
        expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
        expect(response.body).to include_json(message: nil)
      end

      it 'returns status code 401' do
        post api_v1_session_refresh_path
        expect(response).to have_http_status(401)
      end
    end
  end
end
