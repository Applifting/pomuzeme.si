# frozen_string_literal: true

FactoryBot.define do
  factory :news do
    title { FFaker::HipsterIpsum.sentence }
    body { FFaker::HipsterIpsum.sentence }
    news_type


    trait :news_type do
      publication_type { :news }
    end

    trait :from_media_type do
      publication_type { :from_media }
    end
  end
end
