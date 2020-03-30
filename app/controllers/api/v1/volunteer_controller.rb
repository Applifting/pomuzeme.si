class Api::V1::VolunteerController < ApiController

  def profile
    json_response current_volunteer
  end

  def preferences
    json_response current_volunteer, serializer: VolunteerPreferencesSerializer
  end

  def update_preferences
    Api::Volunteer::UpdatePreferences.new(current_volunteer, permitted_params).perform

    head :ok
  end

  def organisations
    json_response current_volunteer.accessed_organisations, each_serializer: OrganisationSerializer
  end

  private

  def permitted_params
    params.permit(:notifications_to_app)
  end
end