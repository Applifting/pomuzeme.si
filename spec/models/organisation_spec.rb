require 'rails_helper'

describe Organisation do
  context 'validations' do
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

  context '#to_s' do
    subject(:organisation) { create(:organisation) }
    let(:expected_result) do
      "#{organisation.name} ~ #{organisation.abbreviation}"
    end

    it { expect(organisation.to_s).to eql(expected_result) }
  end
end
