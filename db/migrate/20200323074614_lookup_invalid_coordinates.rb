class LookupInvalidCoordinates < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          invalid_addresses.each { |address| fix_coordinate address }
        end
      end
    end
  end

  private

  def invalid_coordinate
    @invalid_coordinate ||= Geography::Point.from_s_jtsk x: 0, y: 0
  end

  def invalid_addresses
    Address.where coordinate: invalid_coordinate
  end

  def fix_coordinate(address)
    full_address = address.to_s.gsub 'č.p.', ''
    geo_result = Geocoder.search(full_address).first
    return if geo_result.nil?

    address.update! coordinate: Geography::Point.from_coordinates(latitude: geo_result.latitude, longitude: geo_result.longitude)
  end
end
