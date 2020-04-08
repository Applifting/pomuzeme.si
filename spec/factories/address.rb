# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    street_number { FFaker::AddressDE.building_number }
    street { FFaker::AddressDE.street_name }
    city { FFaker::AddressDE.city }
    city_part { FFaker::AddressDE.city }
    postal_code { FFaker::AddressUK.postcode }
    geo_entry_id { 43 }
    geo_unit_id { 43 }
    geo_provider { 'google_places' }
  end
end
