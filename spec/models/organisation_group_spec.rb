require 'rails_helper'

describe OrganisationGroup do
  context 'validations' do
    subject { create(:organisation_group) }

    it 'should validate uniqueness of organisation scoped to group' do
      organisation_group = subject.dup
      expect(organisation_group.valid?).to be false
      expect(organisation_group.errors.messages[:organisation]).to include(I18n.t('errors.messages.taken'))
    end

    it 'should not validate uniqueness of organisation' do
      organisation_group = subject.dup
      organisation_group.group = create(:group_applifting)
      expect(organisation_group.valid?).to be true
    end
  end

  context 'associations' do
    it { should belong_to(:group) }
    it { should belong_to(:organisation) }
  end

  context '#name' do
    subject { create(:organisation_group) }

    it 'returns name of associated organisation' do
      expect(OrganisationGroup.has_attribute?(:organisation_name)).to be false
      expect(subject.organisation_name).to eq subject.organisation.name
    end
  end
end
