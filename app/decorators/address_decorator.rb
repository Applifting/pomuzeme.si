class AddressDecorator < ApplicationDecorator
  delegate_all

  def latitude
    object.coordinate.y
  end

  def longitude
    object.coordinate.x
  end

  def distance_in_km
    (object.attributes['distance_meters'] / 1_000).round 2
  end

end