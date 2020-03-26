class ApiController < ApplicationController
  include Api::JsonResponse
  include Api::Authorization

  skip_before_action :verify_authenticity_token
  before_action :authorize_request

  rescue_from StandardError do |e|
    error_response(ApiErrors[:UNEXPECTED_ERROR], message: e.message, status: :internal_server_error)
  end
end
