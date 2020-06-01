# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end

  context 'associations' do
    it { should have_many(:coordinating_organisations).conditions(roles: { name: :coordinator }) }
    it { should have_many(:created_requests) }
    it { should have_many(:closed_requests) }
    it { should have_many(:requests) }
    it { should have_many(:organisation_requests) }
    it { should have_many(:coordinating_groups) }
  end

  context '#coordinator_organisation_requests' do
    let(:user) { create(:user) }
    let(:organisation_1) { create(:organisation) }
    let(:organisation_2) { create(:organisation, contact_person_phone: '+420 444 444 444') }
    let!(:request_1) { create(:request, organisation: organisation_1, state: :pending_confirmation) }
    let!(:request_2) { create(:request, organisation: organisation_1) }
    let!(:request_3) { create(:request, organisation: organisation_2) }

    before do
      user.grant :coordinator, organisation_1
    end

    it 'returns only user organisation' do
      expect(user.coordinator_organisation_requests).to match_array([request_2, request_1])
    end
  end

  context '#group_volunteers' do
    let(:user) { create(:user) }
    let(:organisation) { create(:organisation) }
    let(:organisation_group) { create(:organisation_group, organisation: organisation) }
    let!(:group_volunteer) { create(:group_volunteer, group: organisation_group.group) }

    it 'returns group volunteers associated with organisation coordinated by user' do
      allow(user).to receive(:coordinating_organisation_ids).and_return([organisation.id])
      puts user.coordinating_organisations
      expect(user.group_volunteers).to include group_volunteer
    end
  end

  context '#group_coordinators' do
    let(:user_1) { create :user }
    let(:user_2) { create :user }
    let(:organisation_1) { create :organisation }
    let(:organisation_2) { create :organisation }
    let(:group) { create :group }

    before do
      OrganisationGroup.create! group: group, organisation: organisation_1
      OrganisationGroup.create! group: group, organisation: organisation_2
      user_1.grant :coordinator, organisation_1
      user_2.grant :coordinator, organisation_2
    end

    it 'returns coordinators from users group' do
      expect(user_1.group_coordinators).to include user_2
    end

    it 'does not return coordinators outside users group' do
      organisation_2.organisation_groups.destroy_all
      expect(user_1.group_coordinators).not_to include user_2
    end
  end

  context '#organisation_coordinators' do
    let(:user_1) { create :user }
    let(:user_2) { create :user }
    let(:organisation) { create :organisation }

    before do
      user_1.grant :coordinator, organisation
    end

    it 'returns coordinators from same organisation' do
      user_2.grant :coordinator, organisation
      expect(user_1.organisation_coordinators).to include user_2
    end

    it 'does not return coordinators outside same organisation' do
      expect(user_1.organisation_coordinators).not_to include user_2
    end  end

  context '#to_s' do
    let(:user) { build :user }

    it 'is made of name' do
      expect(user.to_s).to eq([user.first_name, user.last_name].compact.join(' '))
    end
  end

  context '#title' do
    let(:user) { build :user }

    it 'is alias for #to_s' do
      expect(user.title).to eq user.to_s
    end
  end

  context '#admin?' do
    let(:user) { build :user }

    it 'is truthy if user has super_admin role' do
      allow_any_instance_of(User).to receive(:roles_name).and_return(['super_admin'])
      expect(user.admin?).to be_truthy
    end

    it 'is falsey if user does not have super_admin role' do
      allow_any_instance_of(User).to receive(:roles_name).and_return(['coordinator'])
      expect(user.admin?).to be_falsey
    end
  end

  context '#coordinator?' do
    let(:user) { create :user }
    let(:organisation) { create :organisation }

    it 'is truthy if user has coordinator role' do
      user.grant :coordinator, organisation
      expect(user.coordinator?).to be_truthy
    end

    it 'is falsey if user does not have coordinator role' do
      user.grant :super_admin, organisation
      expect(user.coordinator?).to be_falsey
    end
  end

  context '#organisation_group' do
    let(:user) { create :user }
    let(:group_1) { create :group }
    let(:group_2) { create :group_applifting }

    it 'returns first associated record of coordinating_groups' do
      allow(user).to receive(:coordinating_groups).and_return(Group.where(id: [group_1.id, group_2.id]).order(id: :desc))
      expect(group_2.id > group_1.id).to be_truthy # quite nasty check
      expect(user.organisation_group).to eq group_2
    end
  end
end
