# frozen_string_literal: true

FactoryBot.define do
  factory :requested_volunteer do
    request
    volunteer
    state { :pending_notification }

    trait :accepted do
      state { :accepted }
    end

    trait :rejected do
      state { :rejected }
    end
  end
end
