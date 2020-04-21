require 'rails_helper'

describe Organisation do
  context 'validations' do
    subject { build(:organisation) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:abbreviation) }
    it { is_expected.to validate_length_of(:abbreviation).is_equal_to(4) }
    it { is_expected.to validate_presence_of(:contact_person) }
    it { is_expected.to validate_presence_of(:contact_person_email) }
    it { is_expected.to validate_presence_of(:contact_person_phone) }

    it { is_expected.not_to allow_values('foo', '1 b@example.c').for(:contact_person_email) }
    it { is_expected.to allow_values('test@example.com').for(:contact_person_email) }
    it { is_expected.not_to allow_values('4443', '+420111222').for(:contact_person_phone) }
    it { is_expected.to allow_values('+420111222333', '420111222333').for(:contact_person_phone) }
  end

  context 'associations' do
    it { should have_many(:coordinators) }
    it { should have_many(:organisation_groups) }
    it { should have_many(:groups) }
    it { should have_many(:requests) }
  end

  context 'scopes' do
    context '.user_group_organisations' do
      let(:user) { create :user }
      let(:organisation) { create :organisation }
      let(:group) { create :group}
      let!(:organisation_group) { OrganisationGroup.create! group: group, organisation: organisation }
      let!(:another_organisation) { create :organisation }

      before do
        allow_any_instance_of(User).to receive(:organisation_group).and_return(group)
      end

      it 'returns organisation belonging to users organisation group' do
        expect(Organisation.user_group_organisations(user)).to include(organisation)
      end

      it 'does not return organisations outside users organisation group' do
        expect(Organisation.user_group_organisations(user)).not_to include(another_organisation)
      end
    end
  end

  context '#to_s' do
    subject(:organisation) { create(:organisation) }
    let(:expected_result) do
      "#{organisation.name} ~ #{organisation.abbreviation}"
    end

    it { expect(organisation.to_s).to eql(expected_result) }
  end
end
