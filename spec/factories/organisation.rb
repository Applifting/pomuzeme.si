# frozen_string_literal: true

FactoryBot.define do
  factory :organisation do
    name { 'Fiendisch Organization for World Larceny' }
    abbreviation { 'FOWL' }
    contact_person { 'Steelbeak' }
    contact_person_email { 'steelbeak@example.com' }
    contact_person_phone { '+420 777 777 777' }
  end
end
