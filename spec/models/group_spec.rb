# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  context 'validations' do
    subject { build(:group) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  context 'associations' do
    it { should have_many(:labels) }
    it { should have_many(:organisation_groups) }
    it { should have_many(:organisations) }
    it { should have_many(:group_volunteers) }
    it { should have_many(:volunteers) }
  end

  context '#add_group_volunteer' do
    let(:volunteer) { create :volunteer }

    context 'when volunteers signed up through organisation form are to be exclusive' do
      let(:group) { create :group, exclusive_volunteer_signup: true }

      it 'should assign volunteer exclusively to group' do
        group_volunteer = group.add_group_volunteer volunteer
        expect(group_volunteer.is_exclusive).to be true
        expect(group_volunteer.group).to eq group
        expect(GroupVolunteer.sources[group_volunteer.source]).to eq GroupVolunteer.sources[:channel]
        expect(GroupVolunteer.recruitment_statuses[group_volunteer.recruitment_status]).to eq GroupVolunteer::DEFAULT_RECRUITMENT_STATUS
      end
    end

    context 'when volunteers signed up through organisation form are to be public' do
      let(:group) { create :group, exclusive_volunteer_signup: false }

      it 'should assign volunteer to group, but volunteers remains public' do
        group_volunteer = group.add_group_volunteer volunteer
        expect(group_volunteer.is_exclusive).to be false
        expect(group_volunteer.group).to eq group
        expect(GroupVolunteer.sources[group_volunteer.source]).to eq GroupVolunteer.sources[:channel]
        expect(GroupVolunteer.recruitment_statuses[group_volunteer.recruitment_status]).to eq GroupVolunteer::DEFAULT_RECRUITMENT_STATUS
      end
    end
  end
end
