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
        volunteers_to_notify = []
        RequestedVolunteer.transaction do
          @volunteers.available_for(@user.organisation_group.id).each do |volunteer|
            volunteers_to_notify << volunteer if volunteer.fcm_active?
            RequestedVolunteer.create! volunteer: volunteer, request: @request, state: @requested_state
          end
          notify_assigned volunteers_to_notify
        end
      end

      private

      def notify_assigned(volunteers)
        return if volunteers.blank?

        Push::Requests::AssignerService.new(@request.id, volunteers).perform
      end
    end
  end
end
