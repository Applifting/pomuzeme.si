module Api
  module Volunteer
    class Register
      attr_reader :volunteer, :params

      def initialize(volunteer, params)
        @volunteer = volunteer
        @params = params
      end

      def perform
        volunteer.assign_attributes params.except(:addresses).merge(confirmed_at: DateTime.now)
        build_addresses
        return validation_error unless volunteer.valid?

        volunteer.save!
      end

      private

      def build_addresses
        params[:addresses].each do |address|
          geo_result = Geocoder.search(address[:place_id], lookup: :google_places_details).first
          volunteer.addresses.build Address.attributes_for_geo_result(geo_result).merge(address.slice(:default))
        end
      end

      def validation_error
        raise InvalidArgumentError, volunteer.errors.full_messages.join("\n")
      end
    end
  end
end
