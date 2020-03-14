class Volunteer < ApplicationRecord
  include SmsConfirmable

  # normalize phone format and add default czech prefix if missings
  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'

  validates :first_name, :last_name, :city, :zipcode, :phone, :email, presence: true
  validates :phone, phony_plausible: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email&.present? }
  validates :zipcode, zipcode: { country_code: :cs }, if: -> { zipcode&.present? } # skip if not present to overcome multiple validation errors

  def with_existing_record
    # TODO: handle update of existing values except identifiers
    Volunteer.unconfirmed.where(phone: normalized_phone, email: self.email).take || self
  end
end