module Push
  module Requests
    class AssignerService < BaseService

      def perform
        super
        mark_as_notified
      end

      def mark_as_notified
        RequestedVolunteer.where(request: request, volunteer_id: volunteers.map(&:id)).each &:notified!
      end

      private

      def payload
        { event: :REQUEST_CREATED,
          request_id: request.id }
      end

      def notification
        { title: I18n.t('push.notifications.request.new.title'),
          body: I18n.t('push.notifications.request.new.body', description: request.text,
                                                              organisation: request.organisation.name) }
      end
    end
  end
end