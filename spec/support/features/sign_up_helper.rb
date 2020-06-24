module Features
  module SignUpHelper
    def stub_partner_url(url)
      ENV['REGISTER_ORG_URL'] = url
    end
  end
end