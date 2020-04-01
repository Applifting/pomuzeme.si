# frozen_string_literal: true

class RequestedVolunteer < ApplicationRecord
  belongs_to :request
  belongs_to :volunteer
  has_many :messages, through: :volunteer

  validates_uniqueness_of :volunteer_id, scope: :request_id

  delegate :first_name, :last_name, :phone, :to_s, to: :volunteer

  before_save :update_timestamps

  enum state: {
    pending_notification: 1,
    notified: 2,
    accepted: 3,
    rejected: 4,
    removed: 5,
    to_be_notified: 6
  }

  private

  def update_timestamps
    self.last_notified_at = DateTime.now if notified?
    self.last_accepted_at = DateTime.now if accepted?
    self.last_rejected_at = DateTime.now if rejected?
    self.last_removed_at = DateTime.now if removed?
  end
end
