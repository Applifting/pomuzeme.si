module Push
  module Requests
    class BaseService

      attr_reader :request, :volunteers

      def initialize(request_id, volunteers)
        @request = Request.eager_load(:organisation).find request_id
        @volunteers = volunteers
      end

      def perform
        Push::SenderService.new(payload, notification, receivers).perform unless receivers.blank?
      end

      private

      def payload
        raise NotImplementedError
      end

      def notification
        raise NotImplementedError
      end

      def receivers
        @receivers ||= volunteers.map(&:fcm_token).compact.uniq
      end
    end
  end
end