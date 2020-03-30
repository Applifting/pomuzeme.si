class Api::V1::OrganisationsController < ApiController

  def index
    json_response Organisation.all, each_serializer: OrganisationSerializer
  end
end