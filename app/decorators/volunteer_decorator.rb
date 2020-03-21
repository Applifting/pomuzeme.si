class VolunteerDecorator < ApplicationDecorator
  delegate_all

  def confirmed?
    object.confirmed?
  end

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def address
    addresses[0]
  end

  def distance_in_km
    (object.attributes['distance_meters'] / 1_000).round 2
  end
end
