class Api::V1::SessionController < ApiController
  skip_before_action :authorize_request

  def new
    volunteer = volunteer_from_params
    return error_response(ApiErrors[:VOLUNTEER_NOT_FOUND], status: :not_found) unless volunteer

    volunteer.obtain_authorization_code
    volunteer.update! fcm_token: permitted_params[:fcm_token] if permitted_params[:fcm_token].present?
    json_response status: :ok
  end

  def create
    volunteer = volunteer_from_params
    return error_response(ApiErrors[:VOLUNTEER_NOT_FOUND], status: :unauthorized) unless volunteer
    return error_response(ApiErrors[:INVALID_VERIFICATION_CODE], status: :unauthorized) unless volunteer.authorize_with(permitted_params[:code])

    json_response token: token(volunteer)
  end

  private

  def volunteer_from_params
    Volunteer.find_by phone: PhonyRails.normalize_number(permitted_params[:phone], country_code: 'cz')
  rescue Phony::NormalizationError
    nil
  end

  def permitted_params
    params.permit :phone, :code, :fcm_token
  end
end
