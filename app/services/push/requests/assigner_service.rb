module Push
  module Requests
    class AssignerService < BaseService
      private

      def payload
        { event: :REQUEST_CREATED,
          request_id: request.id }
      end

      def notification
        { title: I18n.t('push.notifications.request.new.title'),
          body: I18n.t('push.notifications.request.new.body', request: request) }
      end
    end
  end
end