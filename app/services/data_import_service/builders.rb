require 'ffaker'

module DataImportService
  module Builders
    def address_builder(_string)
      raise NotImplementedError, 'Address is cached on Geocoder level'
    end

    def request_builder
      request = build_instance(Request, @row.except('request_address', 'request_organisation', 'request_creator'))
      request.assign_attributes required_volunteer_count: request.required_volunteer_count || 1,
                                address: Address.new_from_string(@row['request_address']),
                                creator: find_or_create_by(User, :full_name, @row['request_creator']),
                                coordinator: find_or_create_by(User, :full_name, @row['request_coordinator'] || @row['group_volunteer_coordinator']),
                                organisation: find_or_create_by(Organisation, :name, @row['request_organisation'])
      request
    end

    def volunteer_builder
      volunteer_data = @row.except('volunteer_address')
                           .merge('volunteer_confirmed_at' => @row['volunteer_created_at'])
      volunteer_instance = build_instance(Volunteer, volunteer_data)
      address            = Address.new_from_string(@row['volunteer_address'])
      volunteer_instance.tap { |v| v.addresses << address }
    end

    def group_volunteer_builder
      return unless @volunteer
      return unless @row['group_volunteer_recruitment_status']

      group_volunteer = build_instance(GroupVolunteer, @row.except('group_volunteer_coordinator'))
      return unless group_volunteer

      error_catcher(group_volunteer) do
        group_volunteer.assign_attributes volunteer: @volunteer,
                                          group: @group,
                                          is_exclusive: true,
                                          source: :migration,
                                          coordinator: find_or_create_by(User, :full_name, @row['group_volunteer_coordinator'])
        group_volunteer
      end
    end
  end
end
