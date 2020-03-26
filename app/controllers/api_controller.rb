class ApiController < ApplicationController
  include Api::JsonResponse
  include Api::Authorization

  skip_before_action :verify_authenticity_token
  before_action :authorize_request

  rescue_from StandardError, with: :unexpected_error
  rescue_from Api::AuthorizationError, with: :authorization_error
  rescue_from Api::InvalidArgumentError, with: :invalid_argument_error

  def serialization_scope
    current_volunteer
  end

  private

  def authorization_error
    error_response ApiErrors[:UNAUTHORIZED_RESOURCE], status: :unauthorized
  end

  def invalid_argument_error
    error_response ApiErrors[:INVALID_ARGUMENT], status: :not_acceptable
  end

  def unexpected_error(exception)
    error_response ApiErrors[:UNEXPECTED_ERROR], message: exception.message, status: :internal_server_error
  end
end
