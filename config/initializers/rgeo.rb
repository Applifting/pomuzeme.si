# frozen_string_literal: true
#
# Having problem with
# undefined method `point' for nil:NilClass ?
# refer to https://stackoverflow.com/questions/31170055/activerecord-postgis-adapter-undefined-method-point-for-nilnilclass

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  # By default, use the GEOS implementation for spatial columns.
  config.default = RGeo::Geos.factory_generator

  # But use a geographic implementation for point columns.
  config.register(RGeo::Geographic.spherical_factory(srid: 4326), geo_type: 'point')
end


class RGeo::Geos::CAPIPointImpl
  alias_method :longitude, :x
  alias_method :lon, :x
  alias_method :latitude, :y
  alias_method :lat, :y
end