class Sms::Provider

  include HTTParty

  base_uri ENV['SMS_BASE_URL']
  default_params apit: ENV['SMS_API_KEY']

  def send_msg(phone, text, msg_id = nil, attempt = 0)
    if ENV['SMS_MOCK'] == 'true'
      puts "SMS verification for #{phone}, TEXT -> #{text}"
    else
      msg_id ||= SecureRandom.hex(16)

      response = self.class.get('/v1/', {query: {chlg: msg_id, rcpt: phone, msgbd: text}})

      # If request returns no success code try it again after one second
      if response.code > 299 && attempt < 1
        sleep 1
        send_msg(phone, text, msg_id, 1)
      end
    end
  end

end