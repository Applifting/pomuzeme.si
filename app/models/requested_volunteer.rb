# frozen_string_literal: true

class RequestedVolunteer < ApplicationRecord
  REQUESTED_VOLUNTEERS_WITH_REQUEST_SQL = 'volunteer_id = %{volunteer_id} AND (request_id IS NULL OR request_id = %{request_id})'.freeze

  # Callbacks
  before_save :update_timestamps, if: :state_changed?

  # Associations
  belongs_to :request
  belongs_to :volunteer
  has_many :messages, primary_key: :volunteer_id, foreign_key: :volunteer_id
  has_one :feedback_request, class_name: 'RequestedVolunteerFeedback', dependent: :delete

  # Attributes
  delegate :first_name, :last_name, :phone, :to_s, to: :volunteer
  delegate :text, :subscriber, :subscriber_organisation, to: :request
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
  validates_presence_of :state, :volunteer, :request

  # Scopes
  scope :with_organisations, ->(*organisation_ids) { joins(:request).where(requests: { organisation_id: organisation_ids }) }
  scope :others, -> { where.not(state: %i[accepted rejected]) }
  scope :with_optional_request_id, ->(volunteer_id, request_id) do
    scope = where(volunteer_id: volunteer_id)
    scope = scope.where(request_id: request_id) if request_id
    scope
  end
  scope :without_feedback_request, -> { left_joins(:feedback_request).where(requested_volunteer_feedbacks: { id: nil }) }
  scope :feedback_time, -> { accepted.left_joins(request: :organisation).where("requested_volunteers.last_accepted_at < (now() - INTERVAL '1 day' * organisations.volunteer_feedback_send_after_days)") }
  scope :feedback_required, -> do left_joins(:feedback_request, request: :organisation)
                                    .merge(Organisation.requires_volunteer_feedback)
                                    .merge(self.without_feedback_request.feedback_time)
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
