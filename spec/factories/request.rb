# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    organisation
    text { 'Request for 5 volunteers' }
    required_volunteer_count { 5 }
    subscriber { 'Subscriber' }
    subscriber_phone { "+420#{rand(111111111...999999999)}" }
    creator
    state_last_updated_at { DateTime.now }
    block_volunteer_until { nil }

    after(:build) do |request|
      request.address = build(:address, addressable: request)
    end

    trait :from_organisation do
      subscriber_organisation { 'Člověk v tísni' }
    end
  end
end
