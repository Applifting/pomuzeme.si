class Volunteer < ApplicationRecord
  include SmsConfirmable
  include Ransackers::VolunteerRansacker

  NEAREST_ADDRESSES_SQL = 'CROSS JOIN (SELECT ST_SetSRID(ST_MakePoint(%{longitude}, %{latitude}), 4326)::geography AS ref_geom) AS r'.freeze

  # Associations
  has_many :addresses, as: :addressable
  has_many :group_volunteers
  has_many :groups, through: :group_volunteers
  has_many :volunteer_labels
  has_many :labels, through: :volunteer_labels

  # normalize phone format and add default czech prefix if missings
  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'

  # Validations
  validates :first_name, :last_name, :phone, presence: true
  validates :phone, phony_plausible: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email&.present? }

  # Scopes
  scope :with_calculated_distance, lambda { |center_point|
                                     joins(:addresses).joins(format(NEAREST_ADDRESSES_SQL, longitude: center_point.longitude, latitude: center_point.latitude))
                                                      .select('volunteers.*', 'ST_Distance(addresses.coordinate, ref_geom) as distance_meters')
                                   }
  scope :with_labels, ->(label_ids) { joins(:volunteer_labels).where(volunteer_labels: { label_id: label_ids }).distinct }

  attr_accessor :address_search_input

  def verify!
    update confirmed_at: Time.zone.now
  end

  def with_existing_record
    Volunteer.unconfirmed.where(phone: normalized_phone).take || self
  end

  private

  # Dirty ransack scopes
  def self.ransackable_scopes(_opts)
    %i[search_nearby has_labels]
  end

  def self.has_labels(*label_ids)
    joins(:volunteer_labels)
      .where('volunteer_labels' => { label_id: label_ids })
      .group(:id)
      .having("count(*) >= #{label_ids.count}")
  end

  def self.search_nearby(encoded_location)
    latitude, longitude = encoded_location.split '#'
    with_calculated_distance Geography::Point.from_coordinates(longitude: longitude, latitude: latitude)
  end
end
