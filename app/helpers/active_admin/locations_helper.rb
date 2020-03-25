module ActiveAdmin
  module LocationsHelper
    def location_autocomplete(callback: 'InitAddressAutocomplete')
      [].tap do |content|
        content << "https://maps.googleapis.com/maps/api/js?key=#{ENV['GOOGLE_MAPS_API_KEY']}&libraries=places&callback=#{callback}"
      end
    end
  end
end
