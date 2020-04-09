module Admin
  module Requests
    class VolunteerNotifier
      attr_reader :user, :request
      def initialize(user, request)
        @user = user
        @request = request
      end

      def perform
        ActiveRecord::Base.transaction do
          request.requested_volunteers.to_be_notified.eager_load(:volunteer).each do |requested_volunteer|
            notify requested_volunteer
          end
        end
      end

      private

      def notify(requested_volunteer)
        # TODO: handle notification type after FCM is merged
        Message.outgoing.sms.message_type_request_offer.create! request: request,
                                                                text: sms_text,
                                                                volunteer_id: requested_volunteer.volunteer_id,
                                                                creator: user
        requested_volunteer.pending_notification!
      end

      def sms_text
        @sms_text ||= I18n.t 'sms.request.offer', identifier: request.identifier, text: request.text
      end
    end
  end
end
