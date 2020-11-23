class VolunteerFeedbackScheduler
  include Sidekiq::Worker

  def perform
    return unless ENV.fetch('ENV_FLAVOR', 'development') == 'production'

    VolunteerFeedback::Sender.batch_send
  end
end
