class RequestDecorator < ApplicationDecorator
  decorates_association :address
  delegate_all

  def volunteer_params
    { request_id: object.id }.merge search_params
  end

  private

  def search_params
    return {} unless object.address

    { order: :distance_meters_asc,
      q: { search_nearby: [object.address.coordinate.latitude.to_s, object.address.coordinate.longitude.to_s].join('#') } }
  end
end
