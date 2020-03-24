# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:creator] do
    first_name { 'First' }
    last_name { 'Last '}
    email { FFaker::Internet.email }
    password { 'Test1234 '}
  end
end
