require 'rails_helper'
require 'support/geocoder_helper'

describe Api::Volunteer::Register do
  include GeocoderHelper
  before(:all) { I18n.locale = :cs }

  describe '#perform' do
    let(:volunteer) { create :volunteer_not_registered }
    let(:volunteer_data) do
      { first_name: 'Test',
        last_name: 'Testic',
        addresses: [{ place_id: 42 }] }
    end

    before { mock_geocoder_search }

    it 'updates volunteer attributes' do
      expect { Api::Volunteer::Register.new(volunteer, volunteer_data).perform }
        .to change { volunteer.reload.first_name }.from('').to('Test')
        .and change { volunteer.reload.last_name }.from('').to('Testic')
        .and change { volunteer.addresses.count }.from(0).to(1)
      expect(volunteer.addresses.first.geo_entry_id).to eq geocoder_search_mock.first.data['place_id']
    end

    it 'updates confirmed_at time' do
      travel_time = Time.zone.local(2020, 0o5, 0o5, 20, 0o0, 0o0)

      travel_to travel_time do
        expect { Api::Volunteer::Register.new(volunteer, volunteer_data).perform }
          .to change { volunteer.confirmed_at }.from(nil).to(travel_time)
      end
    end

    it 'raises exception when record is invalid' do
      volunteer_data[:addresses] = []
      expect { Api::Volunteer::Register.new(volunteer, volunteer_data).perform }
        .to raise_error(Api::InvalidArgumentError)
    end
  end
end
