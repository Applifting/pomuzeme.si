class Sms::Manager < Sms::Provider

  def initialize
    super
  end

  def send_verification_code(code, phone)
    msg = "Overovaci kod pro overeni registrace na portalu pomuzeme.si je: #{code}"
    parsed_phone = phone.sub('+', '')

    send_msg(parsed_phone, msg)
  end

end