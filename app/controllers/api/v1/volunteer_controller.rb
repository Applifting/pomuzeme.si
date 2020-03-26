class Api::V1::VolunteerController < ApiController

  def profile
    json_response current_volunteer
  end

  def preferences
    render json: current_volunteer, serializer: VolunteerPreferencesSerializer
  end

  def update_preferences
    Api::Volunteer::UpdatePreferences.new(current_volunteer, permitted_params).perform

    head :ok
  end

  private

  def permitted_params
    params.permit(:notifications_to_app)
  end
end