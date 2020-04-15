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
    let(:user) { build :user }

    it 'is truthy if user has coordinator role' do
      allow_any_instance_of(User).to receive(:roles_name).and_return(['coordinator'])
      expect(user.coordinator?).to be_truthy
    end

    it 'is falsey if user does not have coordinator role' do
      allow_any_instance_of(User).to receive(:roles_name).and_return(['super_admin'])
      expect(user.coordinator?).to be_falsey
    end
  end
end
