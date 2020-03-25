# frozen_string_literal: true

FactoryBot.define do
  factory :requested_volunteer do
    request
    volunteer
    state { :pending_notification }
  end
end
