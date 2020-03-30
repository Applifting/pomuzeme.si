module Push
  module Requests
    class UpdaterService < BaseService
      private

      def payload
        { event: :REQUEST_UPDATED,
          request_id: request.id }
      end

      def notification
        { title: I18n.t('push.notifications.request.update.title'),
          body: I18n.t('push.notifications.request.update.body', description: request.text,
                                                                 organisation: request.organisation.name) }
      end
    end
  end
end