module Api
  module Volunteer
    class RequestResponse
      def initialize(volunteer, request, params)
        @volunteer = volunteer
        @request = request
        @params = params
      end

      def perform
        validate_params!
        validate_access!
        request.with_lock do
          validate_capacity!
          volunteer_request.update! state: resolve_state
        end
      end

      private

      def requested_volunteer
        @requested_volunteer ||= RequestedVolunteer.find_by request: @request, volunteer: @volunteer
      end

      def resolve_state
        ActiveModel::Type::Boolean.new.cast(@params[:notifications_to_app]) ? :accepted : :rejected
      end

      def validate_capacity!
        return if @request.requested_volunteers.accepted.size < @request.required_volunteer_count

        raise CapacityExceededError
      end

      def validate_access!
        return if volunteer_request.present?

        raise AuthorisationError
      end

      def validate_params!
        return if @params.key?(:response)

        raise InvalidArgumentError
      end
    end
  end
end

class CapacityExceededError < StandardError

end