require 'rails_helper'

describe Organisation do
  describe 'validations' do
    subject { build(:organisation) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:abbreviation) }
    it { is_expected.to validate_presence_of(:contact_person) }
    it { is_expected.to validate_presence_of(:contact_person_email) }
    it { is_expected.to validate_presence_of(:contact_person_phone) }

    it { is_expected.not_to allow_values('foo', '1 b@example.c')
      .for(:contact_person_email) }
    it { is_expected.to allow_values('test@example.com')
      .for(:contact_person_email) }
  end

  describe '#to_s' do
    subject(:organisation) { create(:organisation) }

    it 'returns expected string' do
      expected_string = "#{organisation.name} ~ #{organisation.abbreviation}"
      expect(organisation.to_s).to eql(expected_string)
    end
  end
end
