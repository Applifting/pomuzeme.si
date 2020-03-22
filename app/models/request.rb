# frozen_string_literal: true

class Request < ApplicationRecord
  before_validation :set_state, :set_state_last_updated_at

  has_many :addresses, as: :addressable
  belongs_to :creator, class_name: 'User', foreign_key: :created_by_id
  belongs_to :closer, class_name: 'User', foreign_key: :closed_by_id, optional: true
  belongs_to :coordinator, class_name: 'User', foreign_key: :coordinator_id, optional: true
  belongs_to :organisation
  has_many :requested_volunteers
  has_many :volunteers, through: :requested_volunteers

  validates :text, :required_volunteer_count, :subscriber, presence: true
  validates :creator, :state, :state_last_updated_at, presence: true
  validates :subscriber_phone, phony_plausible: true, presence: true

  enum state: {
    created: 1, # new nobody is working on it
    searching_capacity: 2, # the search for volunteers is ongoing
    pending_confirmation: 3, # the volunteers have been found but the coordinator need to confirm the help with them via phone or other channel
    help_coordinated: 4, # the volunteers help was agreed and the help was coordinated
    closed: 5 # the request was closed. see closed_status to see why
  }

  enum closed_state: {
    fulfilled: 1, # The request was fulfilled
    failed: 2, # The request failed
    irrelevant: 3 # The request became irrelevant
  }

  scope :sorted_state, -> { order(state: :asc, state_last_updated_at: :desc) }

  def set_state
    self.state = :created unless state
  end

  def set_state_last_updated_at
    return unless state_changed? || !state_last_updated_at

    self.state_last_updated_at = DateTime.now
  end
end
