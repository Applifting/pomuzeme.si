class Address < ApplicationRecord

  NEAREST_ADDRESSES_SQL = 'CROSS JOIN (SELECT ST_SetSRID(ST_MakePoint(%{longitude}, %{latitude}), 4326)::geography AS ref_geom) AS r'

  belongs_to :addressable, polymorphic: true, autosave: true

  # Scopes
  scope :with_calculated_distance, ->(center_point) { joins(NEAREST_ADDRESSES_SQL % { longitude: center_point.longitude, latitude: center_point.latitude})
                                                      .select('addresses.*','ST_Distance(addresses.coordinate, ref_geom) as distance_meters')}

  enum country_code: { cz: 'cz' }, _suffix: true
  enum geo_provider: { google_places: 'google_places',
                       cadstudio: 'cadstudio'}, _suffix: true

  validates_presence_of :city, :city_part, :geo_entry_id,
                        :geo_unit_id, :coordinate, :country_code, :geo_provider

  after_initialize :initialize_defaults

  # Little hack to make form with virtual attributes working.
  attr_accessor :latitude, :longitude, :address_search_input

  # Dirty ransack scopes
  def self.ransackable_scopes(_opts)
    [:search_nearby]
  end

  def self.search_nearby(encoded_location)
    latitude, longitude = encoded_location.split '#'
    with_calculated_distance Geography::Point.from_coordinates(longitude: longitude, latitude: latitude)
  end

  def to_s
    [street_number, street, city, city_part, postal_code].compact.join ', '
  end

  private

  def initialize_defaults
    self.country_code = 'cz'
  end
end