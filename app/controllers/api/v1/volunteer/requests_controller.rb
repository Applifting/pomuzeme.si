class Api::V1::Volunteer::RequestsController < ApiController

  def index
    json_response current_volunteer.requested_volunteers.includes(:request)
  end
end
