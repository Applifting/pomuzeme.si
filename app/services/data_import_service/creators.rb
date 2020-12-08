require 'ffaker'

module DataImportService
  module Creators
    def volunteer_creator(attribute, value)
      check_supported_attributes(__method__, attribute, :phone)

      phone = value.gsub(' ', '')
      Volunteer.find_by(phone: phone).presence || save_model(volunteer_builder)
    end

    def request_creator(attribute, text)
      check_supported_attributes(__method__, attribute, :text)

      request = Request.joins(:organisation).where(text: text, organisations: { name: @row['request_organisation'] }).take
      request || save_model(request_builder)
    end

    def user_creator(attribute, name)
      check_supported_attributes(__method__, attribute, :full_name)

      first_name, last_name = name.split(' ')

      user = User.find_by(last_name: last_name || first_name, first_name: first_name)
      user || User.create(last_name: last_name || first_name,
                          first_name: first_name, email: FFaker::Internet.email,
                          phone: FFaker::PhoneNumberIT.phone_number,
                          password: SecureRandom.uuid)
    end

    def organisation_creator(attribute, name)
      check_supported_attributes(__method__, attribute, :name)

      organisation = Organisation.find_or_create_by(name: name) do |new_organisation|
        new_organisation.assign_attributes name: name,
                                           abbreviation: ('a'..'z').to_a.sample(4).join(''),
                                           contact_person: FFaker::Name.name,
                                           contact_person_phone: '+420' + rand(666_666_666..888_888_888).to_s,
                                           contact_person_email: FFaker::Internet.email
      end

      OrganisationGroup.create(organisation: organisation, group: @group) if organisation.organisation_groups.blank?

      organisation
    end

    def label_creator(attribute, name)
      check_supported_attributes(__method__, attribute, :name)

      label = Label.find_by(name: name, group: @group)
      label || Label.new(name: name, group: @group).tap(&:save)
    end

    def requested_volunteer_custom_creator(request)
      RequestedVolunteer.create volunteer: @volunteer,
                                request: request,
                                state: :accepted,
                                last_accepted_at: @row['volunteer_created_at']
    end

    def volunteer_labels_custom_creator
      label_names = @row.select { |k, _v| k.to_s.start_with? 'label_' }.values
      labels = label_names.map do |label_name|
        find_or_create_by(Label, :name, label_name)
      end
      create_volunteer_labels(labels)
    end

    def create_volunteer_labels(labels)
      labels.each do |label|
        VolunteerLabel.create label: label,
                              volunteer: @volunteer,
                              user: find_or_create_by(User, :full_name, @row['group_volunteer_coordinator'])
      end
    end

    def check_supported_attributes(method, attribute, *allowed_attributes)
      raise ArgumentError, "#{method} supports only these attributes: #{allowed_attributes.join(', ')}" unless allowed_attributes.include? attribute
    end
  end
end
