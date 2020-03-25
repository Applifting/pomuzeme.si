# frozen_string_literal: true

class Organisation < ApplicationRecord
  resourcify

  # Associations
  has_many :coordinators,
           -> { joins(:roles).where(roles: { name: :coordinator }) },
           class_name: :User,
           through: :roles,
           source: :users
  has_many :organisation_groups
  has_many :groups, through: :organisation_groups
  has_many :requests

  # Validations
  validates :name, presence: true
  validates :abbreviation, presence: true, length: { is: 4 }
  validates :contact_person, presence: true
  validates :contact_person_email, presence: true
  validates :contact_person_email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { contact_person_email&.present? }
  validates :contact_person_phone, presence: true
  validates :contact_person_phone, phony_plausible: true, uniqueness: true

  # Hooks
  before_validation :upcase_abbreviation
  after_create :create_coordinator
  after_commit :invalidate_organisation_count_cache

  # Scopes
  scope :user_group_organisations, ->(user) { joins(groups: :organisation_groups).where(organisation_groups: { group_id: user.coordinating_groups.pluck(:id) }).distinct }

  def to_s
    "#{name} ~ #{abbreviation}"
  end

  private

  def upcase_abbreviation
    self.abbreviation = abbreviation&.upcase
  end

  def create_coordinator
    Role.create name: :coordinator, resource: self
  end

  def invalidate_organisation_count_cache
    Rails.cache.delete :organisation_count
  end
end
