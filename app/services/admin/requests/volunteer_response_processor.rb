module Admin
  module Requests
    class VolunteerResponseProcessor
      attr_reader :requested_volunteer, :response
      def initialize(requested_volunteer, response)
        @requested_volunteer = requested_volunteer
        @response = response
      end

      def perform
        @requested_volunteer.request.with_lock do
          response ? accept! : reject!

          @requested_volunteer
        end
      end

      private

      def accept!
        raise CapacityExceededError if capacity_exceeded?

        requested_volunteer.update! state: :accepted
      end

      def reject!
        requested_volunteer.update! state: :rejected
      end

      def capacity_exceeded?
        requested_volunteer.request.requested_volunteers.accepted.count >= requested_volunteer.request.required_volunteer_count
      end
    end

    # unify error class after merging mobile API
    class CapacityExceededError < StandardError; end
  end
end
