# frozen_string_literal: true

class Request < ApplicationRecord
  # Hooks
  before_validation :set_state, :set_state_last_updated_at

  # Associations
  has_one :address, as: :addressable, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: :created_by_id
  belongs_to :closer, class_name: 'User', foreign_key: :closed_by_id, optional: true
  belongs_to :coordinator, class_name: 'User', foreign_key: :coordinator_id, optional: true
  belongs_to :organisation
  has_many :requested_volunteers, dependent: :destroy
  has_many :volunteers, through: :requested_volunteers
  has_many :messages

  # Validations
  validates :required_volunteer_count, presence: true
  validates :creator, :state, :state_last_updated_at, presence: true
  validates :subscriber_phone, phony_plausible: true, presence: true
  validates :subscriber_email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { subscriber_email&.present? }
  validates :text, presence: true, length: { maximum: 160 }
  validates :subscriber, presence: true, length: { maximum: 150 }
  validates :closed_note, length: { maximum: 500 }

  # Attributes
  accepts_nested_attributes_for :address
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

  # Scopes
  scope :sorted_state, -> { order(state: :asc, state_last_updated_at: :desc) }
  scope :assignable, -> { where(state: %i[created searching_capacity pending_confirmation]) }
  scope :with_organisations, ->(*organisation_id) { where(organisation_id: organisation_id) }
  scope :in_progress, -> { where('state = 4 AND (fullfillment_date IS NULL OR fullfillment_date > ?)', Time.zone.now) }
  scope :check_fulfillment, -> { where('state = 4 AND fullfillment_date < ?', Time.zone.now) }
  scope :without_coordinator, -> { where(coordinator_id: nil) }
  scope :has_unread_messages, -> { joins(requested_volunteers: :messages).merge(Message.incoming.unread).distinct }

  def title
    [text[0..39], address].compact.join ', '
  end

  def set_state
    self.state = :created unless state
  end

  def set_state_last_updated_at
    return unless state_changed? || !state_last_updated_at

    self.state_last_updated_at = DateTime.now
  end

  def identifier
    @identifier ||= [organisation.abbreviation, ('%04d' % id)].join '-'
  end
end
