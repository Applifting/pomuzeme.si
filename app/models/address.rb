class Address < ApplicationRecord

  NEAREST_ADDRESSES_SQL = 'CROSS JOIN (SELECT ST_SetSRID(ST_MakePoint(%{longitude}, %{latitude}), 4326)::geography AS ref_geom) AS r'\
                          ' WHERE ST_DWithin(coordinate, ref_geom, %{radius}) ORDER BY ST_Distance(coordinate, ref_geom)'.freeze

  belongs_to :addressable, polymorphic: true, autosave: true

  # Scopes
  # radius - value in kilometers
  scope :within_radius_nearest_first, ->(center_point, radius) { joins(NEAREST_ADDRESSES_SQL % { longitude: center_point.longitude,
                                                                                                 latitude: center_point.latitude,
                                                                                                 radius: radius}) }

  enum country_code: { cz: 'cz' }, _suffix: true
  enum geo_provider: { google_places: 'google_places',
                       cadstudio: 'cadstudio'}, _suffix: true

  validates_presence_of :city, :city_part, :geo_entry_id,
                        :geo_unit_id, :coordinate, :country_code, :geo_provider

  after_initialize :initialize_defaults

  # Little hack to make form with virtual attributes working.
  attr_accessor :latitude, :longitude

  def to_s
    [street_number, street, city, city_part, postal_code].compact.join ', '
  end

  private

  def initialize_defaults
    self.country_code = 'cz'
  end
end