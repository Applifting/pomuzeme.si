require 'rails_helper'

describe Volunteer do
  describe 'validations' do
    subject { build(:volunteer) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:phone) }

    it { is_expected.not_to allow_values('foo', '1 b@example.c').for(:email) }
    it { is_expected.to allow_values('test@example.com', '').for(:email) }

    it { expect(build(:volunteer, city: nil)).not_to be_valid}
    it { expect(build(:volunteer, city_part: nil)).not_to be_valid}
    it { expect(build(:volunteer, street: nil)).not_to be_valid}
    it { expect(build(:volunteer, street_number: nil)).not_to be_valid}
    it { expect(build(:volunteer, geo_entry_id: nil)).not_to be_valid}
    it { expect(build(:volunteer, geo_unit_id: nil)).not_to be_valid}
    it { expect(build(:volunteer, geo_coord_x: nil)).not_to be_valid}
    it { expect(build(:volunteer, geo_coord_y: nil)).not_to be_valid}
  end

  describe '#with_existing_record' do
    let_it_be(:volunteer) { create(:volunteer, phone: '+420 666 666 666') }

    it 'returns self if the record with the provided phone does not exist' do
      phone = '+420 555 555 555'
      new_volunteer = described_class.new(phone: phone)

      expect(new_volunteer.with_existing_record).to be(new_volunteer)
    end

    it 'returns the found object if the record with the provided phone exists' do
      phone = '+420 666 666 666'
      new_volunteer = described_class.new(phone: phone)

      expect(new_volunteer.with_existing_record).to eq(volunteer)
    end
  end
end
