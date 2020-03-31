class VolunteerSerializer < ActiveModel::Serializer
  attributes :id,
             :first_name,
             :last_name,
             :email,
             :phone,
             :address,
             :addresses

  def address
    ActiveModelSerializers::SerializableResource.new object.addresses[0]
  end

  def addresses
    ActiveModelSerializers::SerializableResource.new object.addresses
  end
end