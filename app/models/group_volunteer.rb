class GroupVolunteer < ApplicationRecord
  DEFAULT_RECRUITMENT_STATUS = 1

  # Associations
  belongs_to :group
  belongs_to :volunteer
  belongs_to :coordinator, class_name: 'User', foreign_key: :coordinator_id, optional: true

  # Enums
  enum recruitment_status: { waiting_for_contact: 1, onboarding: 2, active: 3, inactive: 4 }
  enum source: { migration: 1, channel: 2, public_pool: 3 }
end
