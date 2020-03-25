module Geography
  class Point
    S_JTSK_TO_WGS_84_SQL = "SELECT ST_AsText(ST_Transform(ST_GeomFromText('POINT(%{x} %{y})',2065),4326)) As wkt_point;".freeze

    # Creates geographic point using Rgeo factory from coordinates in S-JTSK geography system
    def self.from_coordinates(longitude:, latitude:)
      RGeo::Geographic.spherical_factory(srid: 4326).point(longitude, latitude)
    end

    # Convert coordinates from S-JTSK system to WGS-84
    def self.from_s_jtsk(x:, y:)
      result = ActiveRecord::Base.connection.execute(S_JTSK_TO_WGS_84_SQL % { x: x, y: y })
      point = RGeo::Geographic.spherical_factory(srid: 4326).parse_wkt result[0]['wkt_point']
      from_coordinates longitude: point.longitude, latitude: point.latitude
    end
  end
end