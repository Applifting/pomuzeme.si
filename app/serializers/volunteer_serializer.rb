class VolunteerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :address

  def address
    object.addresses[0]
  end
end