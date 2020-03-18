require 'rails_helper'

describe Request do
  describe 'validations' do
    subject { build(:request) }

    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_presence_of(:required_volunteer_count) }
    it { is_expected.to validate_presence_of(:subscriber) }
    it { is_expected.to validate_presence_of(:subscriber_phone) }
    it { is_expected.to validate_presence_of(:fulfillment_date) }

    it { is_expected.to allow_values('+420123456789', '123456789').for(:subscriber_phone) }
    it { is_expected.not_to allow_values('3456789', 'aaaa').for(:subscriber_phone) }
  end

  context 'associations' do
    it { should belong_to(:created_by).class_name('User').required }
    it { should belong_to(:closed_by).class_name('User').optional }
    it { should belong_to(:coordinator).class_name('User').optional }
    it { should belong_to(:organisation).required }
  end

  context 'enums' do
    it { should define_enum_for(:status).with_values(Enums::RequestStatuses.to_hash).backed_by_column_of_type(:string).with_suffix }
    it { should define_enum_for(:closed_status).with_values(Enums::RequestClosedStatuses.to_hash).backed_by_column_of_type(:string).with_suffix }
  end
end
