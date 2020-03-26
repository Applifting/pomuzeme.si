module Api
  module Authorization
    extend ActiveSupport::Concern

    included do
      attr_reader :current_volunteer
    end

    def authorize_request
      puts request.headers['HTTP_AUTHORIZATION']
      puts Api::JsonWebToken.decode(request.headers['HTTP_AUTHORIZATION'].split(' ').last)
      @current_volunteer = ::Volunteer.find Api::JsonWebToken.decode(request.headers['HTTP_AUTHORIZATION'].split(' ').last)[:volunteer_id]
    rescue StandardError => e
      puts e.message
      error_response ApiErrors[:INVALID_TOKEN], status: :unauthorized
    end

    def token(volunteer)
      Api::JsonWebToken.encode volunteer_id: volunteer.id
    end
  end
end