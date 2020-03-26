class Api::V1::Volunteer::RequestsController < ApiController

  def index
    json_response current_volunteer.requested_volunteers.eager_load(request: :address)
  end

  def respond
    request = Request.find permitted_params[:id]
    Api::Volunteer::RequestResponse.new(current_volunteer, request, params).perform

    head :ok
  end

  private

  def permitter_params
    params.permit :id, :response
  end
end
