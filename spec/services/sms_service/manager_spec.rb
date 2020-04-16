require 'rails_helper'

describe SmsService::Manager do
  before(:all) { I18n.locale = :cs }

  describe '.send_welcome_msg' do
    let(:standard_text) { I18n.t 'sms.welcome' }
    let(:partner_text)  { I18n.transliterate I18n.t('sms.welcome_channel', group_name: 'Clovek', group_slug: 'clovek') }
    let(:group)         { Group.new name: 'Clovek', slug: 'clovek' }

    it 'sends standard welcome message to free volunteer' do
      expect(described_class).to receive(:sms_gateway).with('1234', standard_text)

      described_class.send_welcome_msg '1234'
    end

    it 'sends welcome message to channel volunteer' do
      expect(described_class).to receive(:sms_gateway).with('1234', partner_text)

      described_class.send_welcome_msg '1234', group
    end
  end

  describe '.send_verification_code' do
    let(:phone) { '420111222333' }
    let(:code) { 'ABCD' }
    let(:message_text) { I18n.t('sms.verification', code: code) }

    it 'sends message with verification code to phone' do
      expect(described_class).to receive(:sms_gateway).with(phone, message_text)

      described_class.send_verification_code phone, code
    end
  end
end
