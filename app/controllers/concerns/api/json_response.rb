module Api
  module JsonResponse
    extend ActiveSupport::Concern

    def json_response(data, status: :ok)
      render json: data, status: status
    end

    def error_response(error_key, message: nil, status:)
      json_response({ error_key: error_key, message: message }, status: status)
    end
  end
end
