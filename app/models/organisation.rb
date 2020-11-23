# frozen_string_literal: true

class Organisation < ApplicationRecord
  include TranslationsHelper
  include VolunteerFeedback::Helper
  resourcify

  # Associations
  has_many :coordinators,
           -> { joins(:roles).where(roles: { name: :coordinator }) },
           class_name: :User,
           through: :roles,
           source: :users
  has_many :organisation_groups, dependent: :destroy
  has_many :groups, through: :organisation_groups
  has_many :requests, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :abbreviation, presence: true, length: { is: 4 }
  validates :contact_person, presence: true
  validates :contact_person_email, presence: true
  validates :contact_person_email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { contact_person_email&.present? }
  validates :contact_person_phone, presence: true
  validates :contact_person_phone, phony_plausible: true, uniqueness: true
  validates :volunteer_feedback_send_after_days, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: -> { volunteer_feedback_message.present? }
  validates :volunteer_feedback_message, presence: true, if: -> { volunteer_feedback_send_after_days.present? }
  validate :volunteer_feedback_message_interpolation

  # Hooks
  before_validation :upcase_abbreviation
  after_create :create_coordinator
  after_commit :invalidate_organisation_count_cache

  # Scopes
  scope :user_group_organisations, ->(user) { joins(:organisation_groups).where(organisation_groups: { group_id: user.organisation_group.id }) }
  scope :requires_volunteer_feedback, -> { where('volunteer_feedback_message IS NOT NULL AND volunteer_feedback_send_after_days IS NOT NULL') }

  def to_s
    "#{name} ~ #{abbreviation}"
  end

  def self.cached_count
    Rails.cache.fetch :organisation_count do
      Organisation.all.size
    end
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

  def volunteer_feedback_message_interpolation
    return unless volunteer_feedback_message.present?

    message_interpolations = extract_interpolations volunteer_feedback_message
    return if message_interpolations.empty? || (message_interpolations - permitted_interpolations).empty?

    errors.add(:volunteer_feedback_message,
               i18n_model_error(self, 'volunteer_feedback_message.invalid_interpolations',
                                allowed_interpolations: decorated_permitted_interpolations))
  end
end
