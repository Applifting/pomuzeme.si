require 'rails_helper'

describe Api::Volunteer::UpdatePreferences do
  describe '#perform' do
    let(:volunteer) { create :volunteer }
    let(:volunteer_data) do
      { notifications_to_app: true,
        sound: false }
    end

    it 'updates volunteer preferences' do
      expect { Api::Volunteer::UpdatePreferences.new(volunteer, volunteer_data).perform }
        .to change { volunteer.reload.preferences }.from(nil).to(volunteer_data.stringify_keys)
    end

    it 'raises error if unallowed parameter key is present' do
      volunteer_data[:shall_raise] = :error
      expect { Api::Volunteer::UpdatePreferences.new(volunteer, volunteer_data).perform }
        .to raise_error(Api::InvalidArgumentError)
    end
  end
end
