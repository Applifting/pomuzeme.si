# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Label, type: :model do
  context 'validations' do
    subject { create(:label) }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:group_id) }
  end

  context 'associations' do
    it { should belong_to(:group) }
    it { should have_many(:volunteer_labels) }
  end

  context 'scopes' do
    let(:group) { create :group }
    let!(:label_ccc) { create :label, name: 'ccc', group: group }
    let!(:label_aaa) { create :label, name: 'aaa', group: group }
    let!(:label_bbb) { create :label, name: 'bbb', group: group }

    context '.managable_by' do
      skip 'implement after proper user tests'
    end

    context '.alphabetically' do
      it 'sorts labels alphabetically' do
        expect(Label.alphabetically.to_a).to eq [label_aaa, label_bbb, label_ccc]
      end
    end
  end
end
