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

    trait :confirmed do
      confirmed_at { DateTime.now }
    end

    trait :unconfirmed do
      confirmed_at { }
    end

    trait :initialized_authorization do
      authorization_code { '3141' }
      authorization_code_valid_to { 1.minute.from_now }
      authorization_code_attempts { 3 }
    end
  end

  factory :volunteer_not_registered, class: 'Volunteer' do
    first_name { '' }
    last_name { '' }
    phone { "+420#{rand(111111111...999999999)}" }
    email { '' }
    pending_registration { true }
  end
end
