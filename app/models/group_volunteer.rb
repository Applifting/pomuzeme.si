class GroupVolunteer < ApplicationRecord
  DEFAULT_RECRUITMENT_STATUS = 1
  WAITING_FOR_CONTACT = :waiting_for_contact
  ACTIVE = :active
  SRC_PUBLIC_POOL = :public_pool
  IN_RECRUITMENT = [1, 2].freeze

  # Enums
  enum recruitment_status: { WAITING_FOR_CONTACT => 1, onboarding: 2, ACTIVE => 3, inactive: 4 }
  enum source: { migration: 1, channel: 2, SRC_PUBLIC_POOL => 3 }

  # Associations
  belongs_to :group
  belongs_to :volunteer
  belongs_to :coordinator, class_name: 'User', foreign_key: :coordinator_id, optional: true

  # Validations
  validates :volunteer, uniqueness: {  scope: :group }

  # Attributes
  delegate :to_s, :title, to: :volunteer

  # Scopes
  scope :in_recruitment_with, ->(group_id) { where(group_volunteers: { group_id: group_id }).take }
  scope :in_progress, -> { where(recruitment_status: IN_RECRUITMENT) }
  scope :closed, -> { where.not(recruitment_status: IN_RECRUITMENT) }
  scope :unassigned, -> { where(coordinator_id: nil) }
end
