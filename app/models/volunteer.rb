class Volunteer < ApplicationRecord
  include SmsConfirmable

  # normalize phone format and add default czech prefix if missings
  phony_normalize :phone, default_country_code: 'CZ'

  validates :first_name, :last_name, :city, :zipcode, :phone, :email, presence: true
  validates :phone, phony_plausible: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :zipcode, zipcode: { country_code: :cs }, if: -> { zipcode&.present? } # skip if not present to overcome multiple validation errors

end