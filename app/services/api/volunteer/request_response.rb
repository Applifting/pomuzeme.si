module Api
  module Volunteer
    class RequestResponse
      attr_reader :volunteer, :request, :params
      def initialize(volunteer, request, params)
        @volunteer = volunteer
        @request = request
        @params = params
      end

      def perform
        validate_params!
        validate_access!
        request.with_lock do
          # TODO: handle logic in another service class
          validate_capacity!
          requested_volunteer.update!(state: request_accepted? ? :accepted : :rejected)
          request.update! state: resolve_request_state
        end
      end

      private

      def requested_volunteer
        @requested_volunteer ||= RequestedVolunteer.find_by request: request, volunteer: volunteer
      end

      def original_request_accepted_size
        @original_request_accepted_size ||= request.requested_volunteers.accepted.size
      end

      def request_accepted?
        return @request_accepted if defined? @request_accepted

        @request_accepted = ActiveModel::Type::Boolean.new.cast params[:accept]
      end

      def resolve_request_state
        return :searching_capacity unless request_accepted? # Always decreases accepted volunteers count
        return :pending_confirmation if original_request_accepted_size + 1 == request.required_volunteer_count # Current acceptance fills capacity

        :searching_capacity
      end

      def validate_capacity!
        raise Api::Request::CapacityExceededError if request_accepted? && original_request_accepted_size >= request.required_volunteer_count
      end

      def validate_access!
        return if requested_volunteer.present?

        raise Api::AuthorizationError
      end

      def validate_params!
        return if params.key? :accept

        raise Api::InvalidArgumentError
      end
    end
  end
end
