class VolunteerPreferencesSerializer < ActiveModel::Serializer
  attributes :notifications_to_app, :sound

  def notifications_to_app
    object.preferences&.dig('notifications_to_app') || false
  end

  def sound
    object.preferences&.dig('sound') || false
  end
end