class Sms::Manager
  def send_verification_code(code, phone)
    msg = I18n.t('sms.verification', code: code)
    # Sms::NetHost.new.send_msg(phone, msg)
    Sms::O2Connector.new.send_msg(phone, msg)
  end

  def send_authorization_code(code, phone)
    msg = I18n.t('sms.mobile_authorization', code: code)
    # Sms::NetHost.new.send_msg(phone, msg)
    Sms::O2Connector.new.send_msg(phone, msg)
  end

  def self.send_welcome_msg(phone, group = nil)
    if group.present?
      new.send_partner_welcome_msg(phone, group)
    else
      new.send_standard_welcome_msg(phone)
    end
  end

  def send_standard_welcome_msg(phone)
    msg = I18n.t('sms.welcome')

    sms_gateway(phone, msg)
  end

  def send_partner_welcome_msg(phone, group)
    msg = I18n.t('sms.welcome_channel', group_name: group.name, group_slug: group.slug)

    sms_gateway(phone, replace_special_chars(msg))
  end

  def replace_special_chars(text)
    text.tr('ěščřžýáíéúůťďóňĚŠČŘŽÝÁÍÉÚŮŤĎÓŇ', 'escrzyaieuutdonESCRZYAIEUUTDON')
  end

  def sms_gateway(phone, msg)
    # Sms::NetHost.new.send_msg(phone, msg)
    Sms::O2Connector.new.send_msg(phone, msg)
  end
end
