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
end
