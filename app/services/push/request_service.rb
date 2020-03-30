module Push
  class RequestService
    def initialize(request, volunteers)
      @request = request
      @volunteers = volunteers
    end

    def perform
      Push::SenderService.new(payload, notification, receivers).perform
    end

    private

    def payload
      { event: :REQUEST_CREATED,
        request_id: @request.id }
    end

    def notification
      { title: I18n.t('push.notifications.request.new.title'),
        body: I18n.t('push.notifications.request.new.body') }
    end

    def receivers
      @volunteers.map(&:fcm_token).compact.uniq
    end
  end
end
