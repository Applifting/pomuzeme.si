class SessionsController < ApplicationController
  layout 'volunteer_profiles'

  before_action :load_session
  before_action :set_login_description_based_on_redirect, only: %i[new request_code]

  def new
    redirect_to volunteer_profile_path if session[:volunteer_id]
  end

  def request_code
    if @session.valid?
      send_and_persist_verification_code

      render :verify_code
    else
      render :new
    end
  end

  def verify_code
    if @session.code == session[:verification_code] && session[:verification_code_expires] > Time.zone.now
      session.delete :verification_code
      session.delete :verification_code_expires
      session.delete :session_phone
      session[:volunteer_id] = @session.volunteer.id
      @current_volunteer = @session.volunteer

      redirect_to @session.redirect_to.presence || volunteer_profile_path
    else
      @session.errors.add(:code, :not_valid)
    end
  end

  def permitted_params
    params.permit(:phone, :code)
  end

  def logout
    session.delete :volunteer_id
    @current_volunteer = nil

    redirect_to params[:redirect_to].presence || home_page_path
  end

  private

  def set_login_description_based_on_redirect
    redirect = params[:redirect_to] || @session.redirect_to

    @action = helpers.login_screen_text(redirect)
  end

  def load_session
    @session = Session.new(phone: params[:phone] || session[:session_phone], code: params[:code], redirect_to: params[:redirect_to])
  end

  def send_and_persist_verification_code
    code = random_code
    session[:verification_code] = code
    session[:verification_code_expires] = 10.minutes.from_now
    session[:session_phone] = @session.phone

    text = I18n.t('sms.login_code', code: code)
    SmsService.send_text(@session.phone, text) unless Rails.env.development?
    puts "CODE: #{code}" if Rails.env.development?
  end

  def random_code
    charset = Array 0..9 # optionally concat with letter array
    Array.new(4) { charset.sample }.join
  end
end
