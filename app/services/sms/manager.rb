class Sms::Manager < Sms::Provider
  def initialize
    super
  end

  def send_verification_code(code, phone)
    msg = I18n.t('sms.verification', code: code)
    send_msg(phone_without_prefix(phone), msg)
  end

  def send_welcome_msg(phone)
    msg = I18n.t('sms.welcome')
    send_msg(phone_without_prefix(phone), msg)
  end

  private

  def phone_without_prefix(phone)
    phone.sub('+', '')
  end
end
