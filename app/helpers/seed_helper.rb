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

  def self.create_group(organisation:, **args)
    Group.find_or_initialize_by(slug: args[:slug]).tap do |group|
      next if group.persisted?

      group.assign_attributes args
      group.save!
      group.organisations << organisation
    end
  end

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
                                geo_provider: Address.geo_providers[:cadstudio],
                                coordinate: Geography::Point.from_coordinates(latitude: 50.0941253, longitude: 14.4548767)
      volunteer.save!
    end
  end

  def self.create_request(**args)
    request = Request.new(args)
    request.save!
  end
end
