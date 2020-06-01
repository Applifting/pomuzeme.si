# frozen_string_literal: true

FactoryBot.define do
  factory :volunteer do
    first_name { 'Firstname' }
    last_name { 'Lastname' }
    phone { "+420#{rand(111111111...999999999)}" }
    email { FFaker::Internet.email }

    after :build do |volunteer|
      volunteer.addresses << build(:address)
    end
  end
end
