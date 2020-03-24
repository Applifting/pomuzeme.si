class Sms::O2Connector
  include HTTParty

  base_uri ENV['O2_BASE_URL']

  def initialize
    set_p12_cert! if ENV['SMS_MOCK'] != 'true'
  end

  def send_msg(phone, text, attempt = 0)
    if ENV['SMS_MOCK'] == 'true'
      puts "SMS for #{phone}, TEXT -> #{text}"
    else
      query = {
        action: 'send',
        baID: 1_992_125,
        fromNumber: '+420720002125',
        toNumber: phone,
        text: text,
        deliveryReport: 'FALSE',
        intruder: 'FALSE',
        multipart: 'FALSE',
        validityPeriod: 10_000,
        priority: 1
      }
      response = self.class.get('/smsconnector/getpost/GP', { query: query })

      # If request returns no success code try it again after one second
      if response.code > 299 && attempt < 1
        sleep 1
        send_msg(phone, text, 1)
      end
    end
  end

  private

  def set_p12_cert!
    pass = ENV['O2_AUTH_PASS']
    key = ENV['O2_AUTH_KEY']
    crt = ENV['O2_AUTH_CRT']

    p12 = OpenSSL::PKCS12.create(pass, 'auth', OpenSSL::PKey.read(key), OpenSSL::X509::Certificate.new(crt))
    self.class.pkcs12 p12.to_der, pass
  end
end
