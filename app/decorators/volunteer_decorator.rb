class VolunteerDecorator < ApplicationDecorator
  delegate_all

  def confirmed?
    object.confirmed?
  end

  def full_address
    [full_street, [address.city_part, address.city].uniq, address.postal_code].flatten.compact.join(', ')
  end

  def full_street
    [address.street, address.street_number].uniq.compact.join(' ')
  end

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def address
    @address ||= addresses[0]
  end

  def distance_in_km
    (object.attributes['distance_meters'] / 1_000).round 2
  end
end
