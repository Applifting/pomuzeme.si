class AddressRestrictedSerializer < ActiveModel::Serializer
  attributes :street,
             :street_number,
             :city,
             :city_part
end