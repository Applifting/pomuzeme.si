module Admin
  module Requests
    class VolunteerAssigner
      def initialize(user, request, volunteers, requested_state: nil)
        @user = user
        @request = request
        @volunteers = volunteers
        @requested_state = requested_state || :notified
      end

      def perform
        RequestedVolunteer.transaction do
          @volunteers.available_for(@user.organisation_group.id).each do |volunteer|
            RequestedVolunteer.create! volunteer: volunteer, request: @request, state: @requested_state
          end
        end
      end
    end
  end
end
