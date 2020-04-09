# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    name { 'People in need' }
    slug { 'pin' }
    channel_description { 'We help.' }
  end

  factory :group_applifting, class: 'Group' do
    name { 'Applifting' }
    slug { 'app' }
    channel_description { 'We develop things.' }
  end
end
