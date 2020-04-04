require 'rails_helper'

describe SmsService::Manager do
  before(:all) { I18n.locale = :cs }

  describe '.send_welcome_msg' do
    let(:standard_text) { I18n.t 'sms.welcome' }
    let(:partner_text)  { described_class.new.replace_special_chars I18n.t('sms.welcome_channel', group_name: 'Clovek', group_slug: 'clovek') }
    let(:group)         { Group.new name: 'Clovek', slug: 'clovek' }

    it 'sends standard welcome message to free volunteer' do
      expect_any_instance_of(described_class).to receive(:sms_gateway).with('1234', standard_text)

      described_class.send_welcome_msg '1234'
    end

    it 'sends welcome message to channel volunteer' do
      expect_any_instance_of(described_class).to receive(:sms_gateway).with('1234', partner_text)

      described_class.send_welcome_msg '1234', group
    end
  end
end
