class Organisation < ApplicationRecord
  resourcify

  validates :name, presence: true
  validates :abbreviation, presence: true, length: { is: 3 }
  validates :contact_person, presence: true
  validates :contact_person_email, presence: true
  validates :contact_person_email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { contact_person_email&.present? }
  validates :contact_person_phone, presence: true
  validates :contact_person_phone, phony_plausible: true, uniqueness: true

  before_validation :upcase_abbreviation


  private

  def upcase_abbreviation
    self.abbreviation = abbreviation&.upcase
  end
end


