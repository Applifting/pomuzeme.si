class AddressDecorator < ApplicationDecorator
  delegate_all

  def latitude
    object.coordinate.y
  end

  def longitude
    object.coordinate.x
  end

  def full_address
    [object.street_number, object.street, object.city, object.city_part, object.postal_code].reject(&:blank?).join ', '
  end

end