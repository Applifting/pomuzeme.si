class Api::V1::SessionController < ApiController
  skip_before_action :authorize_request, :must_be_registered, except: :refresh

  def new
    return error_response(ApiErrors[:INVALID_CAPTCHA], status: :forbidden) unless valid_recaptcha?
    volunteer = volunteer_from_params
    return error_response(ApiErrors[:VOLUNTEER_NOT_FOUND], status: :not_found) if volunteer.nil? || volunteer.confirmed_at.nil?

    volunteer.obtain_authorization_code
    volunteer.update! fcm_token: permitted_params[:fcm_token] if permitted_params[:fcm_token].present?
    json_response status: :ok
  end

  def create
    volunteer = volunteer_from_params
    return error_response(ApiErrors[:VOLUNTEER_NOT_FOUND], status: :unauthorized) unless volunteer
    return handle_unauthorized(volunteer) unless volunteer.authorize_with(permitted_params[:sms_verification_code])

    json_response token: token(volunteer), registration_in_progress: volunteer.registration_in_progress?
  end

  def refresh
    json_response token: token(current_volunteer)
  end

  private

  def volunteer_from_params
    # normalized_phone = PhonyRails.normalize_number(permitted_params[:phone_number], country_code: 'cz')
    # Volunteer.find_by(phone: normalized_phone) || Volunteer.create!(first_name: '', last_name: '', email: '', phone: normalized_phone, pending_registration: true)
    Volunteer.find_by phone: PhonyRails.normalize_number(permitted_params[:phone_number], country_code: 'cz')
  rescue Phony::NormalizationError
    nil
  end

  def permitted_params
    params.permit :phone_number, :sms_verification_code, :fcm_token, :recaptcha_token
  end

  def valid_recaptcha?
    return true # unless Rails.env.production?

    verify_recaptcha(response: permitted_params[:recaptcha_token], site_key: ENV['RECAPTCHA_MOBILE_SITE_KEY'])
  end

  def handle_unauthorized(volunteer)
    return error_response(ApiErrors[:INVALID_VERIFICATION_CODE], status: :unauthorized) if volunteer.authorization_code_attempts.positive?

    error_response(ApiErrors[:INVALID_VERIFICATION_CODE], status: :too_many_requests)
  end
end
