require 'ffaker'

module DataImportService
  module Builders
    def address_builder(string)
      Address.new_from_string(string)
    end

    def request_builder(*)
      request = build_instance(Request, @row.except('request_address', 'request_organisation'))
      request.assign_attributes required_volunteer_count: 1,
                                address: find_or_build_by(Address, @row['request_address']),
                                creator: find_or_create_by(User, @row['group_volunteer_coordinator']),
                                coordinator: find_or_create_by(User, @row['group_volunteer_coordinator']),
                                organisation: find_or_create_by(Organisation, @row['request_organisation'])
      request
    end

    def volunteer_builder
      volunteer = build_instance(Volunteer, @row.except('volunteer_address'))
      address   = find_or_build_by(Address, @row['volunteer_address'])
      volunteer.tap { |v| v.addresses << address }
    end

    def group_volunteer_builder(volunteer)
      return unless volunteer

      group_volunteer = build_instance(GroupVolunteer, @row.except('group_volunteer_coordinator'))
      return unless group_volunteer

      error_catcher(group_volunteer) do
        group_volunteer.assign_attributes volunteer: volunteer,
                                          group: @group,
                                          is_exclusive: true,
                                          source: :migration,
                                          coordinator: find_or_create_by(User, @row['group_volunteer_coordinator'])
        group_volunteer
      end
    end
  end
end
