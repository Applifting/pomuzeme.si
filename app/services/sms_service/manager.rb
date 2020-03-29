module SmsService
  module Manager
    class << self
      def send_verification_code(phone, code)
        msg = I18n.t('sms.verification', code: code)
        sms_gateway(phone, msg)
      end

      def send_welcome_msg(phone, group = nil)
        if group.present?
          send_partner_welcome_msg(phone, group)
        else
          send_standard_welcome_msg(phone)
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
        SmsService.send_text(phone, msg)
      end
    end
  end
end
