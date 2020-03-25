class RequestDecorator < ApplicationDecorator
  delegate_all

  def volunteer_params
    puts object.address
    puts object.address.coordinate
    { request_id: object.id }.merge search_params
  end

  def full_address
    [full_street, [address&.city_part, address&.city].uniq, address&.postal_code].flatten.compact.join(', ')
  end

  def full_street
    [address&.street, address&.street_number].uniq.compact.join(' ')
  end

  private

  def search_params
    return {} unless object.address

    { order: :distance_meters_asc,
      q: { search_nearby: [object.address.coordinate.latitude.to_s, object.address.coordinate.longitude.to_s].join('#') } }
  end
end
