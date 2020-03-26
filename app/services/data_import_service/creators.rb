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

    def volunteer_labels_creator
      label_names = @row.select { |k, _v| k.to_s.start_with? 'label_' }.values
      labels = label_names.map do |label_name|
        find_or_create_by(Label, label_name)
      end
      volunteer_label_creator(labels)
    end

    def volunteer_label_creator(labels)
      labels.each do |label|
        VolunteerLabel.create label: label,
                              volunteer: @volunteer,
                              user: find_or_create_by(User, @row['group_volunteer_coordinator'])
      end
    end

    def label_creator(name)
      Label.find_or_create_by(name: name) do |label|
        label.group = @group
      end
    end
  end
end
