class AddressDecorator < ApplicationDecorator
  delegate_all

  def latitude
    object.coordinate.y
  end

  def longitude
    object.coordinate.x
  end

end