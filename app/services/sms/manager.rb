class Sms::Manager
  def send_verification_code(code, phone)
    msg = I18n.t('sms.verification', code: code)
    # Sms::NetHost.new.send_msg(phone, msg)
    Sms::O2Connector.new.send_msg(phone, msg)
  end

  def send_welcome_msg(phone, group)
    msg = group.present? ? I18n.t('sms.welcome_channel', group_name: group.name) : I18n.t('sms.welcome')
    # Sms::NetHost.new.send_msg(phone, msg)
    Sms::O2Connector.new.send_msg(phone, msg)
  end
end
