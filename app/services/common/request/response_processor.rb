module Common
  module Request
    class ResponseProcessor
      attr_reader :request, :volunteer, :is_accepted

      def initialize(request, volunteer, is_accepted)
        @request = request
        @volunteer = volunteer
        @is_accepted = is_accepted
      end

      def perform
        validate_access!
        request.with_lock do
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

        @request_accepted = ActiveModel::Type::Boolean.new.cast is_accepted
      end

      def resolve_request_state
        return :searching_capacity unless request_accepted? # Always decreases accepted volunteers count
        return :pending_confirmation if original_request_accepted_size + 1 == request.required_volunteer_count # Current acceptance fills capacity

        :searching_capacity
      end

      def validate_capacity!
        raise CapacityExceededError if request_accepted? && original_request_accepted_size >= request.required_volunteer_count
      end

      def validate_access!
        return if requested_volunteer.present?

        raise AuthorisationError.new(:update, RequestedVolunteer)
      end
    end
  end
end