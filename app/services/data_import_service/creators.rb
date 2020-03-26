require 'ffaker'

module DataImportService
  module Creators
    def request_creator(*)
      save_model(request_builder)
    end

    def user_creator(name)
      first_name, last_name = name.split(' ')

      User.create last_name: last_name || first_name,
                  first_name: first_name, email: FFaker::Internet.email,
                  password: SecureRandom.uuid
    end

    def organisation_creator(name)
      Organisation.create name: name,
                          abbreviation: ('a'..'z').to_a.sample(4).join(''),
                          contact_person: FFaker::Name.name,
                          contact_person_phone: '+420' + rand(666_666_666..888_888_888).to_s,
                          contact_person_email: FFaker::Internet.email
    end

    def requested_volunteer_creator(request, volunteer)
      RequestedVolunteer.create volunteer: volunteer,
                                request: request,
                                state: :accepted,
                                last_accepted_at: @row['volunteer_created_at']
    end
  end
end
