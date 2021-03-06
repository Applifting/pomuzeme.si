require 'rails_helper'

describe SmsConfirmable do
  before(:all) { I18n.locale = :en }

  describe '#confirmed?' do
    subject(:confirmable) { build(:volunteer, confirmed_at: confirmed_at) }

    context 'given confirmed_at is not set, "confirmed?"' do
      let(:confirmed_at) { nil }

      it { expect(confirmable.confirmed?).to be false }
    end

    context 'given confirmed_at is set, "confirmed?"' do
      let(:confirmed_at) { Time.now }

      it { expect(confirmable.confirmed?).to be true }
    end
  end

  describe '#confirm_with' do
    let(:confirmed_at) { nil }
    let(:sms_confirmation_code) { confirmation_code }
    let(:confirmation_code) { 'ABCD' }
    let(:confirmation_valid_to) { 5.minutes.from_now }

    subject(:confirmable) do
      build(:volunteer,
            confirmed_at: confirmed_at,
            confirmation_code: confirmation_code,
            confirmation_valid_to: confirmation_valid_to)
    end

    it 'confirms model' do
      expect do
        confirmable.confirm_with(sms_confirmation_code)
      end.to change(confirmable, :confirmed_at).from(nil)
    end

    context 'given sms code and stored code are nil' do
      let(:sms_confirmation_code) { nil }
      let(:confirmation_code) { nil }

      it 'adds error to confirmable model' do
        confirmable.confirm_with(sms_confirmation_code)
        expect(confirmable.errors.messages.values.flatten)
          .to_not include('is not matching')
      end
    end

    context 'given sms code does not match stored code' do
      let(:sms_confirmation_code) { 'ZYXW' }

      it 'adds error to confirmable model' do
        confirmable.confirm_with(sms_confirmation_code)
        expect(confirmable.errors.messages.values.flatten)
          .to include('is not matching')
      end
    end

    context 'given no confirmation_valid_to is set' do
      let(:confirmation_valid_to) { nil }

      it do
        expect do
          confirmable.confirm_with(sms_confirmation_code)
        end.to raise_error(StandardError)
      end
    end

    context 'given code is expired' do
      let(:confirmation_valid_to) { 5.minutes.ago }

      it 'adds error to confirmable model' do
        confirmable.confirm_with(sms_confirmation_code)
        expect(confirmable.errors.messages.values.flatten)
          .to include('is expired')
      end
    end
  end

  describe '#obtain_confirmation_code' do
    let(:confirmed_at) { nil }
    let(:confirmation_code) { nil }
    let(:confirmation_valid_to) { nil }

    subject(:confirmable) do
      build(:volunteer,
            confirmed_at: confirmed_at,
            confirmation_code: confirmation_code,
            confirmation_valid_to: confirmation_valid_to)
    end

    before do
      allow(SmsService).to receive(:send_text)
    end

    context 'given confirmed_at is not set' do
      before do
        allow(subject).to receive(:can_obtain_code?).and_return(false)
      end

      it 'checks for code reneration rate limit' do
        expect do
          confirmable.obtain_confirmation_code
        end.to raise_error('Token regenerated too early')
      end
    end

    context 'given confirmation code is requested' do
      let(:sms_manager) { double(:sms_manager) }

      before do
        allow(SmsService::Manager).to receive(:send_verification_code).and_return(true)
      end

      it 'updates confirmation_code on model' do
        expect do
          confirmable.obtain_confirmation_code
        end.to change(confirmable, :confirmation_code).from(nil)
      end

      it 'updates confirmation_valid_to on model' do
        expect do
          confirmable.obtain_confirmation_code
        end.to change(confirmable, :confirmation_valid_to).from(nil)
      end

      it 'sends new SMS' do
        expect(sms_manager).to receive(:send_verification_code).once
        allow(SmsService::Manager).to receive(:send_verification_code).and_return(sms_manager.send_verification_code)
        confirmable.obtain_confirmation_code
      end
    end
  end
end
