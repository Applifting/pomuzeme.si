require 'rails_helper'

describe Api::Volunteer::UpdateProfile do
  describe '#perform' do
    let(:volunteer) { create :volunteer, first_name: 'Foo', last_name: 'Bar', email: 'foo@bar.baz', description: nil }
    let(:volunteer_data) do
      { first_name: 'Test',
        last_name: 'Testic',
        email: 'test@testic.cc',
        description: 'I do things' }
    end

    it 'updates volunteer profile' do
      expect { Api::Volunteer::UpdateProfile.new(volunteer, volunteer_data).perform }
        .to change { volunteer.reload.first_name }.from('Foo').to('Test')
        .and change { volunteer.reload.last_name }.from('Bar').to('Testic')
        .and change { volunteer.reload.email }.from('foo@bar.baz').to('test@testic.cc')
        .and change { volunteer.reload.description }.from(nil).to('I do things')
    end

    it 'raises error if validation fails' do
      volunteer_data[:first_name] = nil
      expect { Api::Volunteer::UpdateProfile.new(volunteer, volunteer_data).perform }
        .to raise_error(Api::InvalidArgumentError)
    end
  end
end
