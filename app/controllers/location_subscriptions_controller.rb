class LocationSubscriptionsController < PublicController
  skip_before_action :authorize_current_volunteer

  before_action :build_location_subscription, only: %w[request_code create]

  def request_code
    if @location_subscription.valid?
      send_and_persist_verification_code

      render :verify_code
    else
      flash[:error] = 'Něco se pokazilo :-('
      Raven.extra_context(location_subscription_errors: @location_subscription.errors.messages.to_s)
      Raven.capture_exception StandardError.new 'LocationSubscriptionsController#request_code failed'
      redirect_to requests_path
    end
  end

  def create
    if verify_code_and_cleanup && @location_subscription.valid?
      @location_subscription.save!
      flash[:success] = "Notifikace uložena."
    else
      Raven.extra_context(location_subscription_errors: @location_subscription.errors.messages.to_s)
      Raven.capture_exception StandardError.new 'LocationSubscriptionsController#create failed'
      flash[:error] = 'Něco se pokazilo :-('
    end

    redirect_to requests_path
  end

  private

  def verify_code_and_cleanup
    return true if @current_volunteer.present?

    if params[:code] == session[:verification_code] && session[:verification_code_expires] > Time.zone.now
      session.delete :verification_code
      session.delete :verification_code_expires
      true
    else
      false
    end
  end

  def random_code
    charset = Array 0..9 # optionally concat with letter array
    Array.new(4) { charset.sample }.join
  end

  def send_and_persist_verification_code
    code = random_code
    session[:verification_code] = code
    session[:verification_code_expires] = 10.minutes.from_now
    session[:session_phone] = @location_subscription.phone

    text = I18n.t('sms.location_subscription_verification', code: code, location: @location_subscription.address.to_s)
    SmsService.send_text(@session.phone, text) unless Rails.env.development?
    puts "TEXT: #{text}" if Rails.env.development?
    puts "CODE: #{code}" if Rails.env.development?
  end

  def build_location_subscription
    @location_subscription  = LocationSubscription.new location_subscription_params
    @location_subscription.build_address address_with_coordinate
  end

  def location_subscription_params
    params.require(:location_subscription).permit(:distance, :phone)
  end

  def address_params
    params.require(:location_subscription).permit(
      :street, :city, :street_number, :city_part, :postal_code, :country_code, :geo_entry_id, :geo_unit_id, :geo_coord_x, :geo_coord_y
    )
  end

  def address_with_coordinate
    coordinate = Geography::Point.from_coordinates latitude: address_params[:geo_coord_y].to_d,
                                                   longitude: address_params[:geo_coord_x].to_d
    address_params.except(:geo_coord_x, :geo_coord_y).merge(coordinate: coordinate,
                                                            geo_provider: 'google_places',
                                                            default: true)
  end
end
