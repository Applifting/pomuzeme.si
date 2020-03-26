class Api::V1::Volunteer::RequestsController < ApiController

  rescue_from Api::Request::CapacityExceededError, with: :capacity_exceeded_response

  def index
    json_response current_volunteer.requested_volunteers.eager_load(request: :address)
  end

  def respond
    request = Request.find permitted_params[:id]
    Api::Volunteer::RequestResponse.new(current_volunteer, request, permitted_params).perform
    head :ok
  end

  private

  def permitted_params
    params.permit :id, :accept
  end

  def capacity_exceeded_response
    error_response ApiErrors[:REQUEST_CAPACITY_EXCEEDED], status: :conflict
  end
end
