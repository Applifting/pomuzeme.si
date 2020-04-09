class AddressRestrictedSerializer < ActiveModel::Serializer
  attributes :city,
             :city_part
end