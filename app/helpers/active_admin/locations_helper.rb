module ActiveAdmin
  module LocationsHelper
    def location_autocomplete
      [].tap do |content|
        content << "https://maps.googleapis.com/maps/api/js?key=#{ENV['GOOGLE_MAPS_API_KEY']}&libraries=places&callback=InitAutocomplete"
      end
    end
  end
end
