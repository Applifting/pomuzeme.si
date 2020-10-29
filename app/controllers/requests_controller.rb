class RequestsController < PublicController
  skip_before_action :authorize_current_volunteer, only: [:index]
  before_action :load_request, only: %i[confirm_interest accept]

  def index
    if params[:request_geo_coord_y].present? && params[:request_geo_coord_x].present?
      search = Request.for_web.ransack(search_nearby: encoded_coordinates, order: :distance_meters_asc)
      @requests = search.result.decorate
    else
      @requests = Request.for_web_preloaded.decorate
    end

    @all_requests_count  = Request.for_web.count
  end

  def confirm_interest
    redirect_to(requests_path) && return unless request_permissible
  end

  def accept
    redirect_to(requests_path) && return unless request_permissible

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
    @all_requests_count  = Request.for_web.count
  end


  private

  def encoded_coordinates
    format '%{lat}#%{lon}', lat: params[:request_geo_coord_y], lon: params[:request_geo_coord_x]
  end

  def add_or_update_requested_volunteer
    # If missing, volunteer is created in notified state which is later updated by ReceivedProcessorJob
    @requested_volunteer ||= RequestedVolunteer.find_or_create_by(volunteer: @current_volunteer, request: @request)
    @requested_volunteer.notified!
  end

  def load_request
    @request = Request.assignable.find_by(id: params[:request_id].to_i)&.decorate
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

  def request_permissible
    return true if @request.present?

    flash[:error] = 'Tuto žádost nelze přijmout.'
    Raven.capture_exception StandardError.new('Request cannot be found')
    false
  end
end