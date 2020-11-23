# frozen_string_literal: true

FactoryBot.define do
  factory :organisation do
    name { 'Fiendisch Organization for World Larceny' }
    abbreviation { 'FOWL' }
    contact_person { FFaker::Name.name }
    contact_person_email { FFaker::Internet.email }
    contact_person_phone { "+420#{rand(111111111...999999999)}" }

    trait :with_group do
      transient do
        slug { 'slug' }
        group { create :group, slug: slug }
      end

      after(:create) do |organisation, evaluator|
        create :organisation_group, organisation: organisation, group: evaluator.group
      end
    end

    trait :with_volunteer_feedback_setup do
      volunteer_feedback_message         { 'Feedback from for %{subscriber}' }
      volunteer_feedback_send_after_days { 1 }
    end
  end
end
