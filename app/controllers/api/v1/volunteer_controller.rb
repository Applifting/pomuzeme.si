class Api::V1::VolunteerController < ApiController

  def profile
    json_response current_volunteer
  end
end