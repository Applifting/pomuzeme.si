# frozen_string_literal: true

class Request < ApplicationRecord
  TITLE_MAX_LENGTH = 30
  NEAREST_ADDRESSES_SQL = 'CROSS JOIN (SELECT ST_SetSRID(ST_MakePoint(%{longitude}, %{latitude}), 4326)::geography AS ref_geom) AS r'.freeze

  # Hooks
  before_validation :set_state, :set_state_last_updated_at

  # Associations
  has_one :address, as: :addressable, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: :created_by_id, optional: true
  belongs_to :closer, class_name: 'User', foreign_key: :closed_by_id, optional: true
  belongs_to :coordinator, class_name: 'User', foreign_key: :coordinator_id, optional: true
  belongs_to :organisation, optional: true
  has_many :requested_volunteers, dependent: :destroy
  has_many :volunteers, through: :requested_volunteers
  has_many :messages, dependent: :destroy

  # Validations
  validates :required_volunteer_count, presence: true
  validates :creator, presence: true, unless: :web?
  validates :organisation, presence: true, unless: :web?
  validates :state, :state_last_updated_at, presence: true
  validates :subscriber_phone, phony_plausible: true, presence: true
  validates :subscriber_email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { subscriber_email&.present? }
  validates :text, presence: true, length: { maximum: 160 }
  validates :subscriber, presence: true, length: { maximum: 150 }
  validates :closed_note, length: { maximum: 500 }
  validate :address_presence

  # Attributes
  accepts_nested_attributes_for :address

  phony_normalize :subscriber_phone, default_country_code: 'CZ'
  phony_normalized_method :subscriber_phone, default_country_code: 'CZ'

  enum source: { internal: 1, web: 2 }
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
  scope :for_web, -> { assignable.publishable }
  scope :for_web_preloaded, -> { assignable.publishable.includes(:address, :requested_volunteers).order(created_at: :desc) }
  scope :publishable, -> { where(is_public: true) }
  scope :sorted_state, -> { order(state: :asc, state_last_updated_at: :desc) }
  scope :assignable, -> { where(state: %i[created searching_capacity pending_confirmation]) }
  scope :with_organisations, ->(*organisation_id) { where(organisation_id: organisation_id) }
  scope :in_progress, -> { where('state = 4 AND (fullfillment_date IS NULL OR fullfillment_date > ?)', Time.zone.now) }
  scope :for_followup, -> { where('(state != 5 AND follow_up_after < ?) OR (state = 4 AND fullfillment_date < ?)', Time.zone.now, Time.zone.now) }
  scope :without_coordinator, -> { where(coordinator_id: nil) }
  scope :without_volunteer, -> (volunteer) { where('NOT EXISTS(SELECT 1 from requested_volunteers where request_id = requests.id AND volunteer_id = ?)', volunteer.id) }
  scope :has_unread_messages, -> { joins(:requested_volunteers).where('requested_volunteers.unread_incoming_messages_count > 0').distinct }
  scope :not_closed, -> { where.not(state: :closed) }
  scope :with_calculated_distance, lambda { |center_point|
    joins(:address).joins(format(NEAREST_ADDRESSES_SQL, longitude: center_point.longitude, latitude: center_point.latitude))
                     .select('requests.*', 'addresses.id AS distance_address_id', 'ST_Distance(addresses.coordinate, ref_geom) as distance_meters')
                     .order('distance_meters ASC')
  }

  # Dirty ransack scopes
  def self.ransackable_scopes(_opts)
    %i[search_nearby]
  end

  def self.search_nearby(encoded_location)
    latitude, longitude = encoded_location.split '#'
    with_calculated_distance Geography::Point.from_coordinates(longitude: longitude, latitude: latitude)
  end

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

  def text_title
    return text if text.size <= TITLE_MAX_LENGTH

    text.truncate TITLE_MAX_LENGTH
  end

  def volunteers_by_state
    counts  = requested_volunteers.group(:state)
                                  .count

    accepted_count = counts['accepted'] || 0
    rejected_count = counts['rejected'] || 0
    {
      accepted: accepted_count,
      rejected: rejected_count,
      others: (counts.values.sum - accepted_count - rejected_count)
    }
  end

  def identifier
    # Web request can have blank organisation
    return if organisation.blank?

    @identifier ||= [organisation.abbreviation, ('%04d' % id)].join '-'
  end

  def subscriber_messages
    @subscriber_messages = Message.joins('LEFT JOIN requests r ON r.id = messages.request_id OR r.subscriber_phone = messages.phone')
                                  .where(messages: { message_type: :subscriber }).where('r.id = ?', id)
  end

  private

  def address_presence
    return if address.present? && address.valid?

    errors.add :base, I18n.t('activerecord.errors.models.address.base.inaccurate_address')
  end
end
