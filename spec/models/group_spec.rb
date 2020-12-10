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

  context '#build_group_volunteer' do
    let(:volunteer) { create :volunteer, is_public: false }
    let(:group)     { create :group }

    it 'assigns volunteer to group with correct source and recruitment status' do
      group_volunteer = group.build_group_volunteer volunteer

      expect(group_volunteer.group).to eq group
      expect(GroupVolunteer.sources[group_volunteer.source]).to eq GroupVolunteer.sources[:channel]
      expect(GroupVolunteer.recruitment_statuses[group_volunteer.recruitment_status]).to eq GroupVolunteer::DEFAULT_RECRUITMENT_STATUS
    end

    context 'when volunteers signed up through organisation form are to be exclusive' do
      let(:group)     { create :group, exclusive_volunteer_signup: true }
      let(:volunteer) { build :volunteer }

      it 'should assign volunteer exclusively to group if the volunteer did not exist before' do
        group_volunteer = group.build_group_volunteer volunteer
        expect(group_volunteer.is_exclusive).to be true
      end

      it 'should not assign volunteer exclusively to group if the volunteer existed before as public volunteer' do
        volunteer.update is_public: true

        group_volunteer = group.build_group_volunteer volunteer
        expect(group_volunteer.is_exclusive).to be false
      end
    end

    context 'when volunteers signed up through organisation form are to be public' do
      let(:group) { create :group, exclusive_volunteer_signup: false }

      it 'should assign volunteer to group, but volunteers remains public when volunteer did not exist before' do
        group_volunteer = group.build_group_volunteer volunteer
        expect(group_volunteer.is_exclusive).to be false
      end

      it 'should assign volunteer to group, but volunteers remains public when volunteer existed before as public volunteer' do
        volunteer.update is_public: true

        group_volunteer = group.build_group_volunteer volunteer
        expect(group_volunteer.is_exclusive).to be false
      end
    end
  end
end
