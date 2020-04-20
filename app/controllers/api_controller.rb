class ApiController < ApplicationController
  include Api::JsonResponse
  include Api::Authorization

  skip_before_action :verify_authenticity_token
  before_action :authorize_request, :must_be_registered

  rescue_from StandardError, with: :unexpected_error
  rescue_from AuthorisationError, with: :authorization_error
  rescue_from Api::AuthorisationError, with: :authorization_error
  rescue_from Api::RegistrationError, with: :registration_error
  rescue_from Api::InvalidArgumentError, with: :invalid_argument_error
  rescue_from Api::Address::UnknownLocationError, with: :address_invalid

  def serialization_scope
    current_volunteer
  end

  private

  def authorization_error
    error_response ApiErrors[:UNAUTHORIZED_RESOURCE], status: :unauthorized
  end

  def registration_error
    error_response ApiErrors[:REGISTRATION_REQUIRED], status: :unauthorized
  end

  def invalid_argument_error(exception)
    error_response ApiErrors[:INVALID_ARGUMENT], message: exception.message, status: :not_acceptable
  end

  def unexpected_error(exception)
    error_response ApiErrors[:UNEXPECTED_ERROR], message: exception.message, status: :internal_server_error
  end

  def address_invalid
    error_response ApiErrors[:ADDRESS_INVALID], status: :unauthorized
  end
end
