class AddressDecorator < ApplicationDecorator
  delegate_all

  def latitude
    object.coordinate.y
  end

  def longitude
    object.coordinate.x
  end

  def full_address
    [full_street, [address&.city_part, address&.city].uniq, address&.postal_code].flatten
                                                                                 .compact
                                                                                 .reject(&:blank?)
                                                                                 .join(', ')
  end
  alias to_s full_address

  def full_street
    [address&.street, address&.street_number].uniq
                                             .reject(&:blank?)
                                             .compact.join(' ')
  end

  def distance_in_km(distance_meters)
    (distance_meters / 1_000).round(2).to_s + ' km'
  end
end
