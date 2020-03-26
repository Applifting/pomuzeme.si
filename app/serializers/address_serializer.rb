class AddressSerializer < ActiveModel::Serializer
  attributes :id,
             :street,
             :street_number,
             :city,
             :city_part,
             :geo_entry_id,
             :latitude,
             :longitude,
             :postal_code,
             :country_code

  def latitude
    object.coordinate.latitude
  end

  def longitude
    object.coordinate.longitude
  end
end