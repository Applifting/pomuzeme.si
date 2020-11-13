class Volunteer < ApplicationRecord
  include SmsConfirmable
  include Ransackers::VolunteerRansacker

  NEAREST_ADDRESSES_SQL = 'CROSS JOIN (SELECT ST_SetSRID(ST_MakePoint(%{longitude}, %{latitude}), 4326)::geography AS ref_geom) AS r'.freeze
  AVAILABLE_VOLUNTEERS_CONDITIONS = 'group_volunteers.id is null OR group_volunteers.is_exclusive = false OR (group_volunteers.is_exclusive = true and group_volunteers.group_id = %{group_id})'.freeze
  # TODO: is exclusivity check here really necessary?
  NOT_RECRUITED_BY_CONDITIONS = 'group_volunteers.id is null OR (group_volunteers.is_exclusive = false and group_volunteers.group_id != %{group_id})'.freeze

  # Associations
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :group_volunteers, dependent: :destroy
  has_many :groups, through: :group_volunteers
  has_many :messages, dependent: :destroy
  has_many :volunteer_labels, dependent: :destroy
  has_many :labels, through: :volunteer_labels
  has_many :volunteer_skills, dependent: :destroy
  has_many :skills, through: :volunteer_skills
  has_many :volunteer_interests, dependent: :destroy
  has_many :interests, through: :volunteer_interests
  has_many :requested_volunteers, dependent: :destroy
  has_many :requests, through: :requested_volunteers

  # Attributes
  accepts_nested_attributes_for :addresses

  # normalize phone format and add default czech prefix if missings
  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'

  # Validations
  validates :first_name, :last_name, presence: true, unless: -> { registration_in_progress? }
  validates :addresses, length: { minimum: 1 }, unless: -> { registration_in_progress? }
  validates :phone, phony_plausible: true, uniqueness: true, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email&.present? }

  # Scopes
  scope :with_calculated_distance, lambda { |center_point|
    joins(:addresses).joins(format(NEAREST_ADDRESSES_SQL, longitude: center_point.longitude, latitude: center_point.latitude))
                     .select('volunteers.*', 'addresses.id AS distance_address_id', 'ST_Distance(addresses.coordinate, ref_geom) as distance_meters')
                     .order('distance_meters ASC')
  }
  scope :with_labels, ->(label_ids) { joins(:volunteer_labels).where(volunteer_labels: { label_id: label_ids }).distinct }
  scope :available_for, ->(group_id) { left_joins(:group_volunteers).where(format(AVAILABLE_VOLUNTEERS_CONDITIONS, group_id: group_id)) }
  scope :exclusive_for, ->(group_id) { left_joins(:group_volunteers).where(group_volunteers: { is_exclusive: true, group_id: group_id }) }
  scope :verified_by, ->(group_id) { left_joins(:group_volunteers).where(group_volunteers: { group_id: group_id, recruitment_status: 3 }) }
  scope :not_recruited_by, ->(group_id) { left_joins(:group_volunteers).where(format(NOT_RECRUITED_BY_CONDITIONS, group_id: group_id)) }
  scope :assigned_to_request, ->(request_id) { left_joins(:requested_volunteers).where(requested_volunteers: { request_id: request_id }) }
  scope :blocked, -> { left_joins(:requests).where(requested_volunteers: { state: :accepted }, requests: { block_volunteer_until: Time.now.. }) }
  scope :not_blocked, -> { where.not(id: blocked) }
  scope :push_notification_active, -> { where('preferences @> ?', { notifications_to_app: true }.to_json) }

  after_commit :invalidate_volunteer_count_cache

  attr_accessor :address_search_input

  def verify!
    update! confirmed_at: Time.zone.now if confirmed_at.nil?
  end

  def with_existing_record
    Volunteer.unconfirmed.where(phone: normalized_phone).take || self
  end

  def address
    addresses.first
  end

  def to_s
    "#{first_name} #{last_name}"
  end
  alias title to_s

  def self.cached_count
    Rails.cache.fetch :volunteer_count do
      Volunteer.confirmed.size
    end
  end

  def push_notifications?
    preferences.try(:[], 'notifications_to_app')
  end

  # TODO: handle recognition of inactive users with FCM token
  def fcm_active?
    fcm_token.present?
  end

  def accessed_organisations
    Organisation.left_joins(:organisation_groups).where(organisation_groups: { group_id: group_ids })
  end

  def registration_in_progress?
    confirmed_at.nil? && pending_registration?
  end

  def process_manual_registration(current_user)
    update(confirmed_at: Time.zone.now)
    GroupVolunteer.create(group: current_user.organisation_group,
                          volunteer: self,
                          coordinator: current_user,
                          source: :manual,
                          recruitment_status: :onboarding,
                          is_exclusive: true)
  end

  private

  # Dirty ransack scopes
  def self.ransackable_scopes(_opts)
    %i[search_nearby has_labels has_interests]
  end

  def self.has_labels(*label_ids)
    where(id: Volunteer.unscoped.joins(:volunteer_labels)
                                .where('volunteer_labels' => { label_id: label_ids })
                                .group(:id)
                                .having("count(*) >= #{label_ids.count}").select(:id))
  end

  def self.has_interests(*interest_ids)
    where(id: Volunteer.unscoped.left_joins(:volunteer_interests)
                                .where('volunteer_interests' => { interest_id: interest_ids })
                                .or(Volunteer.unscoped.left_joins(:volunteer_interests).where('volunteer_interests' => { interest_id: nil }))
                                .group(:id)
                                .having("count(*) >= #{interest_ids.count}").select(:id))
  end

  def self.search_nearby(encoded_location)
    latitude, longitude = encoded_location.split '#'
    with_calculated_distance Geography::Point.from_coordinates(longitude: longitude, latitude: latitude)
  end

  def invalidate_volunteer_count_cache
    Rails.cache.delete :volunteer_count
  end
end
