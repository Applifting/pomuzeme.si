module Api
  module Volunteer
    class UpdatePreferences
      def initialize(volunteer, params)
        @volunteer = volunteer
        @params = params
      end

      def perform
        validate_params!
        @volunteer.preferences ||= {}
        @volunteer.preferences['notifications_to_app'] = ActiveModel::Type::Boolean.new.cast @params[:notifications_to_app]
        @volunteer.preferences['sound'] = ActiveModel::Type::Boolean.new.cast @params[:sound]
        @volunteer.save!
      end

      private

      def validate_params!
        return if @params.has_key?(:notifications_to_app)

        raise InvalidArgumentError
      end
    end
  end
end