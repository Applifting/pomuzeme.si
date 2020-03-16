# frozen_string_literal: true

module SeedHelper
  def self.create_super_admin(email:, password:)
    User.find_or_initialize_by(email: email).tap do |user|
      next if user.persisted?

      user.assign_attributes password: password, password_confirmation: password
      user.save!
      user.add_role :super_admin
    end
  end

  def self.create_coordinator(email:, password:, organisation:)
    User.find_or_initialize_by(email: email).tap do |user|
      next if user.persisted?

      user.assign_attributes password: password, password_confirmation: password
      user.save!
      user.grant :coordinator, organisation
    end
  end

  def self.create_organisation(**args)
    Organisation.find_or_initialize_by(name: args[:name]).tap do |organisation|
      next if organisation.persisted?

      organisation.assign_attributes abbrevation: args[:abbrevation],
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
                                  street: args[:street],
                                  phone: args[:phone],
                                  email: args[:email]
      volunteer.save!
    end
  end
end
