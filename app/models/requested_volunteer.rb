# frozen_string_literal: true

class RequestedVolunteer < ApplicationRecord
  REQUESTED_VOLUNTEERS_WITH_REQUEST_SQL = 'volunteer_id = %{volunteer_id} AND (request_id IS NULL OR request_id = %{request_id})'.freeze

  # Callbacks
  before_save :update_timestamps

  # Associations
  belongs_to :request
  belongs_to :volunteer
  has_many :messages, primary_key: :volunteer_id, foreign_key: :volunteer_id

  # Attributes
  delegate :first_name, :last_name, :phone, :to_s, to: :volunteer
  delegate :text, :subscriber, to: :request
  enum state: {
    pending_notification: 1,
    notified: 2,
    accepted: 3,
    rejected: 4,
    removed: 5,
    to_be_notified: 6
  }

  # Validations
  validates_uniqueness_of :volunteer_id, scope: :request_id

  # Scopes
  scope :with_organisations, ->(*organisation_ids) { joins(:request).where(requests: { organisation_id: organisation_ids }) }
  scope :with_optional_request_id, ->(volunteer_id, request_id) do
    scope = where(volunteer_id: volunteer_id)
    scope = scope.where(request_id: request_id) if request_id
    scope
  end

  def unread_incoming_messages
    Message.incoming.unread.where(format(REQUESTED_VOLUNTEERS_WITH_REQUEST_SQL, volunteer_id: volunteer_id, request_id: request_id))
  end

  private

  def update_timestamps
    self.last_notified_at = DateTime.now if notified?
    self.last_accepted_at = DateTime.now if accepted?
    self.last_rejected_at = DateTime.now if rejected?
    self.last_removed_at = DateTime.now if removed?
  end
end
