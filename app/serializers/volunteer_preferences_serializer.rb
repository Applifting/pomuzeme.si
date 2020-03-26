class VolunteerPreferencesSerializer < ActiveModel::Serializer
  attributes :notifications_to_app

  def notifications_to_app
    object.preferences&.dig('notifications_to_app') || false
  end
end