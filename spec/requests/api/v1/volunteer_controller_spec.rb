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
      it_behaves_like 'unauthorized user' do
        let(:http_method) { :get }
        let(:url_path) { api_v1_volunteer_profile_path }
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

      context 'with invalid preferences' do
        let(:invalid_params) { { email: 'foobar' } }
        it 'returns invalid argument error' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_profile_path,
                         params: invalid_params
          expect(response.body).to include_json(error_key: 'INVALID_ARGUMENT')
          expect(response.body).to include_json(message: 'E-mail is invalid')
        end

        it 'returns status code 406' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_profile_path,
                         params: invalid_params
          expect(response).to have_http_status(406)
        end
      end
    end

    context 'as unauthorized volunteer' do
      it_behaves_like 'unauthorized user' do
        let(:http_method) { :put }
        let(:url_path) { api_v1_volunteer_profile_path }
      end
    end
  end

  describe 'GET /api/v1/volunteer/preferences' do
    context 'as authorized volunteer' do
      let(:volunteer) { create :volunteer, :confirmed }

      it 'returns serialized volunteer data' do
        authorized_get volunteer: volunteer,
                       path: api_v1_volunteer_preferences_path
        expect(response.body).to eq VolunteerPreferencesSerializer.new(volunteer).to_json
      end

      it 'returns status code 200' do
        authorized_get volunteer: volunteer,
                       path: api_v1_volunteer_preferences_path
        expect(response).to have_http_status(200)
      end
    end

    context 'as unauthorized volunteer' do
      it_behaves_like 'unauthorized user' do
        let(:http_method) { :get }
        let(:url_path) { api_v1_volunteer_preferences_path }
      end
    end
  end

  describe 'PUT /api/v1/volunteer/preferences' do
    let(:volunteer) { create :volunteer, :confirmed }

    context 'as authorized volunteer' do
      it 'calls UpdateProfile service' do
        params = { notifications_to_app: 'true',
                   sound: 'false' }
        expect(Api::Volunteer::UpdatePreferences).to receive(:new).with(volunteer, ActionController::Parameters.new(params).permit!)

        authorized_put volunteer: volunteer,
                       path: api_v1_volunteer_preferences_path,
                       params: params
      end

      it 'returns status code 200' do
        params = { notifications_to_app: 'true',
                   sound: 'false' }
        authorized_put volunteer: volunteer,
                       path: api_v1_volunteer_preferences_path,
                       params: params
        expect(response).to have_http_status(200)
      end

      context 'with invalid preferences' do
        it 'returns invalid argument error' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_preferences_path
          expect(response.body).to include_json(error_key: 'INVALID_ARGUMENT')
          expect(response.body).to include_json(message: 'Api::InvalidArgumentError')
        end

        it 'returns status code 406' do
          authorized_put volunteer: volunteer,
                         path: api_v1_volunteer_preferences_path
          expect(response).to have_http_status(406)
        end
      end
    end

    context 'as unauthorized volunteer' do
      it_behaves_like 'unauthorized user' do
        let(:http_method) { :put }
        let(:url_path) { api_v1_volunteer_preferences_path }
      end
    end
  end

  describe 'GET /api/v1/volunteer/organisations' do
    context 'as authorized volunteer' do
      let(:organisation_group_1) { create :organisation_group }
      let!(:organisation_1) { organisation_group_1.organisation }
      let(:group) { organisation_group_1.group }
      let(:organisation_group_2) { create :organisation_group, group: group }
      let!(:organisation_2) { organisation_group_2.organisation }
      let(:group_volunteer) { create :group_volunteer, group: group }
      let(:volunteer_with_group) { group_volunteer.volunteer }
      let(:volunteer_without_group) { create :volunteer }


      context 'for volunteer belonging to group' do
        it 'returns organisations from groups where volunteer is member' do
          authorized_get volunteer: volunteer_with_group,
                         path: api_v1_volunteer_organisations_path
          expect(response.body).to eq [OrganisationSerializer.new(organisation_1),
                                       OrganisationSerializer.new(organisation_2)].to_json
        end

        it 'returns status code 200' do
          authorized_get volunteer: volunteer_with_group,
                         path: api_v1_volunteer_organisations_path
          expect(response).to have_http_status(200)
        end
      end

      context 'for volunteer belonging to no group' do
        it 'returns organisations from groups where volunteer is member' do
          authorized_get volunteer: volunteer_without_group,
                         path: api_v1_volunteer_organisations_path
          expect(response.body).to eq [].to_json
        end

        it 'returns status code 200' do
          authorized_get volunteer: volunteer_without_group,
                         path: api_v1_volunteer_organisations_path
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'as unauthorized volunteer' do
      it_behaves_like 'unauthorized user' do
        let(:http_method) { :get }
        let(:url_path) { api_v1_volunteer_organisations_path }
      end
    end
  end
end
