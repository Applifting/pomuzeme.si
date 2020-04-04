module MessageStateManipulation
  extend ActiveSupport::Concern

  def process_state_changed
    mark_volunteer_notified if outgoing? && message_type_request_offer?
  end

  private

  def mark_volunteer_notified
    RequestedVolunteer.where(request_id: request_id, volunteer_id: volunteer_id).update_all state: :notified
  end
end