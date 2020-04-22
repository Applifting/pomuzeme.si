module Features
  module RecaptchaHelper
    def stub_recaptcha_key
      Recaptcha.configuration.secret_key = 22
      Recaptcha.configuration.site_key = 21
    end
  end
end