# typed: true
# frozen_string_literal: true

module AddressForm
  class Builder
    attr_reader :data, :address

    def initialize(address_params)
      @data = address_params
    end

    def self.build(address_params)
      new(address_params).tap(&:build_address)
    end

    def build_address
      @address = data.is_a?(Address) ? data : find_or_build_address_from_params
    end

    private

    def find_or_build_address_from_params
      find_or_build_address_from_params
    end

    def form_submitted?
      !data.is_a? Address
    end

    def find_or_build_address_from_params
      load_and_update_existing_address
    end

    def load_and_update_existing_address
      Address.find_by(id: data[:id]).tap do |address|
        next Address.new if address.nil?

        address.assign_attributes(data.except(:latitude, :longitude))
        address.coordinate = Geography::Point.from_coordinates latitude: data[:latitude],
                                                               longitude: data[:longitude]
        address.geo_provider = Address.geo_providers[:google_places]
      end
    end
  end
end
