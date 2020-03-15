module SmsConfirmable
  extend ActiveSupport::Concern

  included do
    scope :confirmed, -> { where.not(confirmed_at: nil) }
    scope :unconfirmed, -> { where(confirmed_at: nil) }
  end

  CONFIRMATION_CODE_VALIDITY = 10 # minutes
  CONFIRMATION_CODE_LENGTH = 4
  CONFIRMATION_CODE_REPEAT_BREAK = 30 # seconds


  def confirmed?
    !confirmed_at.nil?
  end

  def confirm_with(sms_confirmation_code)
    return errors.add(:confirmation_code, :confirmed) if confirmed?
    return errors.add(:confirmation_code, :not_matching) if sms_confirmation_code != self.confirmation_code
    return errors.add(:confirmation_code, :expired) if Time.now > confirmation_valid_to

    confirm!
  end

  def obtain_confirmation_code
    raise StandardError, 'Token already generated' unless confirmed_at.nil?
    raise StandardError, 'Token regenerated too early' unless can_obtain_code?

    regenerate_confirmation_code!
    Sms::Manager.new.send_verification_code confirmation_code, phone
  end

  private

  def regenerate_confirmation_code!
    update! confirmation_code: random_code, confirmation_valid_to: CONFIRMATION_CODE_VALIDITY.minutes.from_now
  end

  def confirm!
    update! confirmed_at: Time.now
  end

  def random_code
    charset = Array 0..9 # optionally concat with letter array
    Array.new(CONFIRMATION_CODE_LENGTH) { charset.sample }.join
  end

  def can_obtain_code?
    confirmation_code.nil? || (code_generated_before > CONFIRMATION_CODE_REPEAT_BREAK.seconds)
  end

  def code_generated_before
    Time.now - (confirmation_valid_to - CONFIRMATION_CODE_VALIDITY.minutes)
  end
end