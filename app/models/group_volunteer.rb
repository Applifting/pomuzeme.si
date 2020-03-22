class GroupVolunteer < ApplicationRecord
  DEFAULT_RECRUITMENT_STATUS = 1
  WAITING_FOR_CONTACT = :waiting_for_contact
  IN_RECRUITMENT = [1, 2].freeze

  # Enums
  enum recruitment_status: { WAITING_FOR_CONTACT => 1, onboarding: 2, active: 3, inactive: 4 }
  enum source: { migration: 1, channel: 2, public_pool: 3 }

  # Associations
  belongs_to :group
  belongs_to :volunteer
  belongs_to :coordinator, class_name: 'User', foreign_key: :coordinator_id, optional: true

  # Validations
  validates :volunteer, uniqueness: {  scope: :group }
end
