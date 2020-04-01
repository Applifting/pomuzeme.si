class Api::V1::VolunteerController < ApiController

  skip_before_action :must_be_registered, only: :register

  def profile
    json_response current_volunteer
  end

  def update_profile
    Api::Volunteer::UpdateProfile.new(current_volunteer, profile_params).perform

    head :ok
  end

  def register
    Api::Volunteer::Register.new(current_volunteer, register_params).perform if current_volunteer.registration_in_progress?

    head :ok
  end

  def preferences
    json_response current_volunteer, serializer: VolunteerPreferencesSerializer
  end

  def update_preferences
    Api::Volunteer::UpdatePreferences.new(current_volunteer, preferences_params).perform

    head :ok
  end

  def organisations
    json_response current_volunteer.accessed_organisations, each_serializer: OrganisationSerializer
  end

  private

  def preferences_params
    params.permit(:notifications_to_app, :sound)
  end

  def register_params
    params.permit(:first_name, :last_name, :phone, :email, :description, addresses: [:place_id])
  end

  def profile_params
    params.permit(:first_name, :last_name, :email, :description)
  end
end