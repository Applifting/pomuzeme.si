# frozen_string_literal: true

class RequestedVolunteer < ApplicationRecord
  belongs_to :request
  belongs_to :volunteer

    delegate :first_name, :last_name, to: :volunteer

  enum state: {
    pending_notification: 1,
    notified: 2,
    accepted: 3,
    rejected: 4,
    removed: 5
  }
end
