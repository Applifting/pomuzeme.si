require 'rails_helper'

describe Organisation do
  describe 'validations' do
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

    describe 'validate volunteer_feedback_message_interpolation' do
      context 'when allowed interpolations are specified by *.attributes.organisation.volunteer_feedback_interpolations I18n' do
        let(:organisation) { build :organisation, volunteer_feedback_send_after_days: 1 }

        before :each do
          allow(organisation).to receive(:permitted_interpolations).and_return %w[city country]
        end

        it 'marks record invalid if the volunteer_feedback_message contains other than allowed interpolations' do
          organisation.volunteer_feedback_message = 'There are some %{city} %{allowed} params.'
          organisation.valid?

          expect(organisation).not_to be_valid
          expect(organisation.errors.messages[:volunteer_feedback_message]).to include /Povolené parametry jsou: %\{city\}, %\{country\}./
        end

        it 'marks record valid if the volunteer_feedback_message contains only allowed interpolations' do
          organisation.volunteer_feedback_message = 'There are some %{city} %{country} params.'
          organisation.valid?

          expect(organisation).to be_valid
          expect(organisation.errors.messages[:volunteer_feedback_message]).to be_blank
        end
      end
    end
  end

  describe 'associations' do
    it { should have_many(:coordinators) }
    it { should have_many(:organisation_groups) }
    it { should have_many(:groups) }
    it { should have_many(:requests) }
  end

  describe 'scopes' do
    describe '.user_group_organisations' do
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

  describe '#to_s' do
    subject(:organisation) { create(:organisation) }
    let(:expected_result) do
      "#{organisation.name} ~ #{organisation.abbreviation}"
    end

    it { expect(organisation.to_s).to eql(expected_result) }
  end
end
