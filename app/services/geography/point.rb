module Geography
  class Point
    # Creates geographic point using Rgeo factory from coordinates in S-JTSK geography system
    def self.from_coordinates(latitude:, longitude:)
      RGeo::Geographic.spherical_factory(srid: 4326).point(latitude, longitude)
    end

    def self.from_s_jtsk(x:, y:)
      point = JTSK::Converter.new.to_wgs84(x, y)
      from_coordinates latitude: point.latitude, longitude: point.longitude
    end
  end
end