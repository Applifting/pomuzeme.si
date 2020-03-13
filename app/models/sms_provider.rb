class SmsProvider

  TWILIO_SENDER_ALPHANUMERIC = 'Pomuzeme.si'.freeze

  def initialize
    unless ENV['SMS_MOCK']
      @client = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_TOKEN'])
    end
  end

  def send_verification_code(code, receiver_phone)
    if ENV['SMS_MOCK'] == 'true'
      puts "SMS verification for #{receiver_phone}, CONFIRM -> #{code}"
    else
      body = get_message_body(code)
      begin
        send_sms(body, TWILIO_SENDER_ALPHANUMERIC, receiver_phone)
      rescue Twilio::REST::RestError => error
        # 21612 - The 'To' phone number is not currently reachable via SMS or MMS
        # 21606 - The 'From' phone number provided is not a valid, message-capable Twilio phone number
        if [21612, 21606].include?(error.code)
          send_sms(body, ENV['TWILIO_SENDER_PHONE'], receiver_phone)
        else
          raise error
        end
      end
    end
  end

  private

  def get_message_body(code)
    "Oveřovací kód pro oveření registrace na portálu Pomuzeme.si: #{code}"
  end

  def send_sms(body, sender_phone, receiver_phone)
    @client.messages.create(
        body: body,
        from: sender_phone,
        to: receiver_phone
    )
  end

end
