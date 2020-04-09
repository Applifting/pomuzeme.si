# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupVolunteer, type: :model do
  context 'validations' do
    subject { create(:group_volunteer) }

    it 'should validate uniqueness of volunteer scoped to group' do
      group_volunteer = subject.dup
      expect(group_volunteer.valid?).to be_falsey
      expect(group_volunteer.errors.messages[:volunteer]).to include(I18n.t('errors.messages.taken'))
    end

    it 'should not validate uniqueness of volunteer' do
      group_volunteer = subject.dup
      group_volunteer.group = nil
      expect(create(:group_volunteer, group: create(:group_applifting)).valid?).to be_truthy
    end
  end

  context 'associations' do
    it { should belong_to(:group) }
    it { should belong_to(:volunteer) }
    it { should belong_to(:coordinator).class_name('User').optional }
  end

  context 'enums' do
    it { should define_enum_for(:source).with_values(migration: 1, channel: 2, public_pool: 3) }
    it { should define_enum_for(:recruitment_status).with_values(waiting_for_contact: 1, onboarding: 2, active: 3, inactive: 4) }
  end

  context 'scopes' do
    let(:group) { create :group }
    let(:user) { create :user }
    let!(:volunteer_pending) { create :group_volunteer, recruitment_status: :waiting_for_contact, group: group, coordinator: user }
    let!(:volunteer_onboarding) { create :group_volunteer, recruitment_status: :onboarding, group: group }
    let!(:volunteer_active) { create :group_volunteer, recruitment_status: :active, group: group }

    context '.in_recruitment_with' do
      let!(:volunteer_for_applifting) { create :group_volunteer, group: create(:group_applifting) }
      let!(:volunteer_for_people) { create :group_volunteer, group: group }

      it 'returns associations scoped to group' do
        expect(GroupVolunteer.in_recruitment_with(group.id).pluck(:group_id)).to all(be group.id)
      end
    end

    context '.in_progress' do
      it 'returns only volunteers in recruitment' do
        scope = GroupVolunteer.in_progress.to_a

        expect(scope).to include(volunteer_pending)
        expect(scope).to include(volunteer_onboarding)
        expect(scope).not_to include(volunteer_active)
      end
    end

    context '.closed' do
      it 'returns only volunteers with finished recruitment' do
        scope = GroupVolunteer.closed.to_a

        expect(scope).not_to include(volunteer_pending)
        expect(scope).not_to include(volunteer_onboarding)
        expect(scope).to include(volunteer_active)
      end
    end

    context '.unassigned' do
      it 'returns only associations without coordinator' do
        expect(GroupVolunteer.unassigned.pluck :coordinator_id).to all(be_nil)
      end
    end
  end
end
