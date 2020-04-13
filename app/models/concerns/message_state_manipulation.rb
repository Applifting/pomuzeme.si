module MessageStateManipulation
  extend ActiveSupport::Concern

  def process_state_changed
    mark_volunteer_notified if outgoing? && message_type_request_offer? # TODO: change only on pending to sent transition
  end

  private

  def mark_volunteer_notified
    # TODO: skip unless volunteer is waiting for notification or limit call
    RequestedVolunteer.where(request_id: request_id, volunteer_id: volunteer_id).update_all state: :notified
  end
end