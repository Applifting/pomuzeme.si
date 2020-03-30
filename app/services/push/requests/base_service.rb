module Push
  module Requests
    class BaseService
      def initialize(request, volunteers)
        @request = request
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
        @receivers ||= @volunteers.map(&:fcm_token).compact.uniq
      end
    end
  end
end