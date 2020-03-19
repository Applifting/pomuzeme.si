class Volunteer < ApplicationRecord
  include SmsConfirmable

  NEAREST_ADDRESSES_SQL = 'CROSS JOIN (SELECT ST_SetSRID(ST_MakePoint(%{longitude}, %{latitude}), 4326)::geography AS ref_geom) AS r'

  # Associations
  has_many :addresses, as: :addressable

  # normalize phone format and add default czech prefix if missings
  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'

  # Validations
  validates :first_name, :last_name, :phone, presence: true
  validates :phone, phony_plausible: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email&.present? }

  scope :with_calculated_distance, ->(center_point) { joins(:addresses).joins(NEAREST_ADDRESSES_SQL % { longitude: center_point.longitude, latitude: center_point.latitude})
                                                                       .select('volunteers.*','ST_Distance(addresses.coordinate, ref_geom) as distance_meters')}

  attr_accessor :address_search_input


  # Dirty ransack scopes
  def self.ransackable_scopes(_opts)
    [:search_nearby]
  end

  def self.search_nearby(encoded_location)
    latitude, longitude = encoded_location.split '#'
    with_calculated_distance Geography::Point.from_coordinates(longitude: longitude, latitude: latitude)
  end

  def with_existing_record
    Volunteer.unconfirmed.where(phone: normalized_phone).take || self
  end
end
