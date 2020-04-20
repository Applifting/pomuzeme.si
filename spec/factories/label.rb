# frozen_string_literal: true

FactoryBot.define do
  factory :label do
    name { FFaker::HipsterIpsum.word }
    description { FFaker::HipsterIpsum.sentence }
    group
  end
end
