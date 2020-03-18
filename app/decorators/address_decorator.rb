# frozen_string_literal: true

class AddressDecorator < ApplicationDecorator
  delegate_all

  def latitude
    object.coordinate.y
  end

  def longitude
    object.coordinate.x
  end

  def full_address
    [object.street, object.street_number, object.city, object.city_part].reject(&:blank?).join ', '
  end

end
