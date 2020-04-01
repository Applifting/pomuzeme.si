# frozen_string_literal: true

class RequestedVolunteer < ApplicationRecord
  belongs_to :request
  belongs_to :volunteer
  has_many :messages, through: :volunteer

  validates_uniqueness_of :volunteer_id, scope: :request_id

  delegate :first_name, :last_name, :phone, :to_s, to: :volunteer
  delegate :text, :subscriber, to: :request

  # Scopes
  scope :with_organisations, ->(*organisation_ids) { joins(:request).where(requests: { organisation_id: organisation_ids }) }

  enum state: {
    pending_notification: 1,
    notified: 2,
    accepted: 3,
    rejected: 4,
    removed: 5
  }
end
