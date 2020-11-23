module VolunteerFeedback::Sender
  extend VolunteerFeedback::Helper

  def self.batch_send
    RequestedVolunteer.feedback_required
                      .includes(:volunteer, request: :organisation)
                      .each do |requested_volunteer|
      call requested_volunteer
    end
  end

  def self.call(requested_volunteer)
    request_text      = requested_volunteer.request.organisation.volunteer_feedback_message
    interpolated_text = interpolate_message request_text, requested_volunteer

    ActiveRecord::Base.transaction do
      msg = Message.outgoing.sms.create! message_type: :feedback_request,
                                         text: interpolated_text,
                                         volunteer_id: requested_volunteer.volunteer_id,
                                         request_id: requested_volunteer.request_id,
                                         phone: requested_volunteer.volunteer.phone

      RequestedVolunteerFeedback.create! requested_volunteer: requested_volunteer

      Messages::SenderJob.perform_later msg.id
    end
  end
end
