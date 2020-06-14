require 'jwt'
module Api
  class JsonWebToken
    SECRET_KEY = ENV.fetch('SECRET_KEY_BASE')

    def self.encode(payload, exp = 30.days.from_now)
      payload[:exp] = exp.to_i
      ::JWT.encode(payload, SECRET_KEY)
    end

    def self.decode(token)
      decoded = ::JWT.decode(token, SECRET_KEY)[0]
      HashWithIndifferentAccess.new decoded
    end
  end
end