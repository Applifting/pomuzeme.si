module SeedHelper
  def self.create_volunteer(**args)
    Volunteer.find_or_initialize_by(phone: args[:phone]).tap do |volunteer|
      next if volunteer.persisted?

      volunteer.assign_attributes first_name: args[:first_name],
                                  last_name: args[:last_name],
                                  phone: args[:phone],
                                  email: args[:email]

      volunteer.addresses.build city: args[:city],
                                city_part: args[:city],
                                street: args[:street],
                                street_number: args[:street],
                                postal_code: args[:zipcode],
                                geo_entry_id: 42, #fake data below, maybe make robust later
                                geo_unit_id: 42,
                                coordinate: Geography::Point.from_coordinates(latitude: 50.0941253, longitude: 14.4548767)
      volunteer.save!
    end
  end
end