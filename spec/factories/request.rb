# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    association :created_by, factory: :user
    association :coordinator, factory: :user
    association :closed_by, factory: :user
    organisation
    address
    text { 'Humble Request' }
    required_volunteer_count { 10 }
    subscriber { 'John Black' }
    subscriber_phone { '+420123456789' }
    status { 'closed' }
    fulfillment_date { 1.day.from_now }
    closed_note { 'Done' }
    closed_at { 1.day.ago }
    closed_status { 'fulfilled' }
    is_published { true }
  end
end
