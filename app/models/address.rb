class Address < ApplicationRecord
  NEAREST_ADDRESSES_SQL = 'CROSS JOIN (SELECT ST_SetSRID(ST_MakePoint(%{longitude}, %{latitude}), 4326)::geography AS ref_geom) AS r'.freeze

  belongs_to :addressable, polymorphic: true, autosave: true

  # Scopes
  scope :with_calculated_distance, lambda { |center_point|
                                     joins(format(NEAREST_ADDRESSES_SQL, longitude: center_point.longitude, latitude: center_point.latitude))
                                       .select('addresses.*', 'ST_Distance(addresses.coordinate, ref_geom) as distance_meters')
                                   }
  scope :default, -> { where default: true }

  enum geo_provider: { google_places: 'google_places',
                       cadstudio: 'cadstudio' }, _suffix: true

  validates_presence_of :city, :city_part, :geo_entry_id,
                        :geo_unit_id, :coordinate, :country_code, :geo_provider
  validates_uniqueness_of :default, scope: [:addressable_type, :addressable_id], if: -> { default }

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

  def self.new_from_string(string)
    Address.new attributes_for_geo_result(Geocoder.search(string).first)
  end

  def self.attributes_for_geo_result(result)
    return {} if result.nil?

    find_property = proc do |type, property|
      component = result.data['address_components'].find { |c| c['types'].include?(type) } || {}
      component[property]
    end

    location = result.data['geometry']['location']
    city     = find_property['locality', 'long_name'] || find_property['administrative_area_level_2', 'long_name']

    { country_code: find_property['country', 'short_name'].downcase,
      postal_code: find_property['postal_code', 'long_name'] || '',
      city: city,
      city_part: find_property['neighborhood', 'long_name'] || city,
      street: find_property['route', 'long_name'],
      street_number: find_property['street_number', 'long_name'] || '',
      coordinate: Geography::Point.from_coordinates(latitude: location['lat'], longitude: location['lng']),
      geo_entry_id: result.data['place_id'],
      geo_unit_id: result.data['place_id'],
      geo_provider: 'google_places' }
  end

  def to_s
    [street_number, street, city, city_part, postal_code].uniq.compact.join ', '
  end

  def only_address_errors?
    errors.keys.map(&:to_s).none? { |key| key.start_with? 'addressable' }
  end

  private

  def initialize_defaults
    self.country_code ||= 'cz'
    self.geo_unit_id ||= geo_entry_id
    self.coordinate ||= Geography::Point.from_coordinates latitude: latitude,
                                                          longitude: longitude
    self.geo_provider ||= :google_places
  end
end
