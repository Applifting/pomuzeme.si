module Api
  module Volunteer
    class UpdateProfile
      attr_reader :volunteer, :params

      def initialize(volunteer, params)
        @volunteer = volunteer
        @params = params
      end

      def perform
        @volunteer.assign_attributes @params
        return validation_error unless @volunteer.valid?

        @volunteer.save!
      end

      private

      def validation_error
        raise InvalidArgumentError, @volunteer.errors.full_messages.join("\n")
      end
    end
  end
end
