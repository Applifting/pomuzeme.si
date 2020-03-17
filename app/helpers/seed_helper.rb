# frozen_string_literal: true

module SeedHelper
  def self.create_user(**args)
    User.find_or_initialize_by(email: args[:email]).tap do |user|
      next if user.persisted?

      user.assign_attributes password: args[:password],
                             password_confirmation: args[:password_confirmation],
                             first_name: args[:first_name],
                             last_name: args[:last_name]
      user.save!
    end
  end

  def self.create_super_admin(**args)
    user = create_user args
    user.add_role :super_admin
    user
  end

  def self.create_coordinator(**args)
    user = create_user args
    user.grant :coordinator, args[:organisation]
    user
  end

  def self.create_organisation(**args)
    Organisation.find_or_initialize_by(name: args[:name]).tap do |organisation|
      next if organisation.persisted?

      organisation.assign_attributes abbreviation: args[:abbreviation],
                                     business_id_number: args[:business_id_number],
                                     contact_person: args[:contact_person],
                                     contact_person_phone: args[:contact_person_phone],
                                     contact_person_email: args[:contact_person_email]
      organisation.save!
    end
  end

  def self.create_volunteer(**args)
    Volunteer.find_or_initialize_by(phone: args[:phone]).tap do |volunteer|
      next if volunteer.persisted?

      volunteer.assign_attributes first_name: args[:first_name],
                                  last_name: args[:last_name],
                                  zipcode: args[:zipcode],
                                  city: args[:city],
                                  city_part: args[:city],
                                  street: args[:street],
                                  street_number: args[:street],
                                  phone: args[:phone],
                                  email: args[:email],
                                  geo_entry_id: 42, #fake data below, maybe make robust later
                                  geo_unit_id: 42,
                                  geo_coord_x: 42,
                                  geo_coord_y: 42
      volunteer.save!
    end
  end

  def self.create_request(**args)
    Request.find_or_initialize_by(text: args[:text], subscriber: args[:subscriber]).tap do |request|
      next if request.persisted?

      address = { street: args[:street],
                  street_number: args[:street_number],
                  city: args[:city],
                  city_part: args[:city_part],
                  geo_entry_id: 42,
                  geo_unit_id: 42,
                  geo_cord: RGeo::Geographic.spherical_factory(srid: 4326).point(args[:geo_coord_x], args[:geo_coord_y]),
                  postal_code: args[:postal_code],
                  country_code: args[:country_code] }

      request.assign_attributes text: args[:text],
                                required_volunteer_count: args[:required_volunteer_count],
                                subscriber: args[:subscriber],
                                subscriber_phone: args[:subscriber_phone],
                                created_by: args[:created_by],
                                coordinator: args[:coordinator],
                                organisation: args[:organisation],
                                status: args[:status],
                                fulfillment_date: args[:fulfillment_date],
                                closed_note: args[:closed_note],
                                closed_at: args[:closed_at],
                                closed_status: args[:closed_status],
                                closed_by: args[:closed_by],
                                is_published: args[:is_published],
                                address_attributes: address

      request.save!
    end
  end
end
