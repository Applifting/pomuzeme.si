# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupVolunteer, type: :model do
  describe 'validations' do
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

  describe 'associations' do
    it { should belong_to(:group) }
    it { should belong_to(:volunteer) }
    it { should belong_to(:coordinator).class_name('User').optional }
  end

  describe 'enums' do
    it { should define_enum_for(:source).with_values(migration: 1, channel: 2, public_pool: 3) }
    it { should define_enum_for(:recruitment_status).with_values(waiting_for_contact: 1, onboarding: 2, active: 3, inactive: 4) }
  end
end
