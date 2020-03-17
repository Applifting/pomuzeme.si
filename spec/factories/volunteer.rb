# frozen_string_literal: true

FactoryBot.define do
  factory :volunteer do
    first_name { 'Firstname' }
    last_name { 'Lastname' }
    phone { '+420 444 444 444' }
    email { 'test@example.com' }
    street { 'Main Street' }
    street_number { '555' }
    city { 'Prague' }
    city_part { 'Center' }
    geo_entry_id { '567' }
    geo_unit_id { 'A56' }
    geo_coord_x { 14.4378005 }
    geo_coord_y { 50.0755381 }
  end
end
