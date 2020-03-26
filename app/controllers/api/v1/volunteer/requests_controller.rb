class Api::V1::Volunteer::RequestsController < ApiController

  def active
    json_response Request.all
  end
end
