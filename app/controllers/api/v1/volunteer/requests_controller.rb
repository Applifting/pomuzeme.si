class Api::V1::Volunteer::RequestsController < ApiController

  def index
    json_response current_volunteer.requested_volunteers.eager_load(request: :address)
  end
end
