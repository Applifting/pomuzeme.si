# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:creator] do
    first_name { 'First' }
    last_name { 'Last '}
    email { FFaker::Internet.email }
    phone { FFaker::PhoneNumberDE.international_phone_number }
    password { 'Test1234 '}
    initialize_with { User.find_or_initialize_by email: email }

    trait :with_organisation_group do
      transient do
        organisation { create(:organisation, :with_group) }
      end

      after(:create) do |user, evaluator|
        user.grant :coordinator, evaluator.organisation
      end
    end
  end
end
