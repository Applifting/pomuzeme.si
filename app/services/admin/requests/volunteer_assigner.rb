module Admin
  module Requests
    class VolunteerAssigner

      DEFAULT_STATE = 'to_be_notified'.freeze

      def initialize(user, request, volunteers, requested_state: nil)
        @user = user
        @request = request
        @volunteers = volunteers
        @requested_state = requested_state || DEFAULT_STATE
      end

      def perform
        @failed_volunteers = []

        RequestedVolunteer.transaction do
          @volunteers.available_for(@user.organisation_group.id).each do |volunteer|
            assign_volunteer_to_request(volunteer)
          end
        end

        @failed_volunteers
      end

      def assign_volunteer_to_request(volunteer)
        begin
          RequestedVolunteer.create! volunteer: volunteer, request: @request, state: @requested_state
        rescue ActiveRecord::RecordInvalid => e
          @failed_volunteers << volunteer
          Raven.extra_context(volunteer_id: volunteer.id, request_id: @request, user_id: @user.id, user_full_name: @user.to_s)
          Raven.capture_exception e
        end
      end
    end
  end
end
