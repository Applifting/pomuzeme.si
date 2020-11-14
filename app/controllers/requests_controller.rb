class RequestsController < PublicController
  RECAPTCHA_THRESHOLD = ENV['RECAPTCHA_THRESHOLD_REQUEST']&.to_f

  include Recaptchable

  skip_before_action :authorize_current_volunteer, only: %i[index new need_volunteers create new_request_accepted confirm_interest]
  before_action :load_and_authorize_request, only: %i[confirm_interest accept]

  def index
    if params[:request] && address_params[:geo_coord_y].present? && address_params[:geo_coord_x].present?
      search = Request.for_web.ransack(search_nearby: encoded_coordinates, order: :distance_meters_asc)
      @requests = search.result.decorate
      build_location_subscription
      build_request
      @closest_request_km = @requests.first.distance_km
    else
      @request = Request.new
      @requests = Request.for_web_preloaded.decorate
    end

    @all_requests_count  = Request.for_web.count
  end

  def new
    @request = Request.web.new.decorate
  end

  def need_volunteers
  end

  def create
    @request = Request.web.new(request_params).decorate
    merge_non_model_fields!

    address  = @request.build_address address_with_coordinate

    if registration_valid && @request.save!
      SlackBot.send_new_request_notification @request, admin_organisation_request_path(@request)
      redirect_to new_request_accepted_path
    else
      render :new
    end
  end

  def new_request_accepted; end

  def confirm_interest; end

  def accept
    @requested_volunteer = RequestedVolunteer.find_by(volunteer: @current_volunteer, request_id: params[:request_id])

    if @requested_volunteer&.accepted?
      flash[:warn] = 'Tuto žádost už jste jednou přijal/a.'

      redirect_to(requests_path) && return
    else
      add_or_update_requested_volunteer
      log_acceptance_message
    end

    redirect_to(request_accepted_path) && return
  end

  def request_accepted
    @all_requests_count = Request.for_web.count
  end


  private

  def merge_non_model_fields!
    @request.text = @request.text + ". Covid pozitivní v zařízení: #{params[:request][:covid_presence] == '1' ? 'ano' : 'ne'}"
    @request.text = @request.text + ". Promo na FB: #{params[:request][:publish_facebook] == '1' ? 'ano' : 'ne'}"
    @request.text = @request.text + ". Publikovat na web: #{params[:request][:is_public] == '1' ? 'ano' : 'ne'}"
  end

  def build_request
    @request  = Request.new
    @request.build_address address_with_coordinate
  end

  def build_location_subscription
    @location_subscription  = LocationSubscription.new
    @location_subscription.build_address address_with_coordinate
  end

  def encoded_coordinates
    format '%{lat}#%{lon}', lat: address_params[:geo_coord_y], lon: address_params[:geo_coord_x]
  end

  def add_or_update_requested_volunteer
    # If missing, volunteer is created in notified state which is later updated by ReceivedProcessorJob
    @requested_volunteer ||= RequestedVolunteer.find_or_create_by(volunteer: @current_volunteer, request: @request)
    @requested_volunteer.notified!
  end

  def load_and_authorize_request
    @request = Request.for_web.assignable.find_by(id: params[:request_id].to_i)&.decorate
    return true if @request.present?

    flash[:error] = 'Tato žádost o dobrovolníky neexistuje, nebo nelze přijmout.'
    Raven.capture_exception StandardError.new('Request cannot be found')
    redirect_to requests_path
  end

  def registration_valid
    resolve_recaptcha(:new_request, @request, RECAPTCHA_THRESHOLD) && @request.valid?
  end

  def request_params
    params.require(:request).permit(:text, :subscriber, :subscriber_phone, :subscriber_organisation, :required_volunteer_count)
  end

  def address_params
    params.require(:request).permit(
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

  def log_acceptance_message
    message = Message.create! volunteer: @current_volunteer,
                              request_id: params[:request_id],
                              direction: :incoming,
                              state: :received,
                              channel: :web,
                              text: 'Ano'

    Messages::ReceivedProcessorJob.perform_later message
  end
end