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
        requested_volunteer.volunteer.fcm_active? ? notify_push(requested_volunteer) : notify_sms(requested_volunteer)
        requested_volunteer.pending_notification!
      end

      def notify_sms(requested_volunteer)
        Message.outgoing.sms.message_type_request_offer.create! request: request,
                                                                text: sms_text,
                                                                volunteer_id: requested_volunteer.volunteer_id,
                                                                creator: user
      end

      def notify_push(requested_volunteer)
        Push::Requests::AssignerService.new(request.id, [requested_volunteer.volunteer]).perform
      end

      def sms_text
        @sms_text ||= I18n.t 'sms.request.offer', identifier: request.identifier, text: request.text
      end
    end
  end
end
