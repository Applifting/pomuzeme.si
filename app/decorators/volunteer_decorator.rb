class VolunteerDecorator < ApplicationDecorator
  delegate_all

  def confirmed?
    object.confirmed?
  end

  def full_address
    [full_street, [object.city_part, object.city].uniq, object.zipcode].flatten.compact.join(', ')
  end

  def full_street
    [object.street, object.street_number].uniq.compact.join(' ')
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
