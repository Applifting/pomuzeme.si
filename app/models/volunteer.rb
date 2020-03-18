class Volunteer < ApplicationRecord
  include SmsConfirmable

  # Associations
  has_many :addresses, as: :addressable

  # normalize phone format and add default czech prefix if missings
  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'

  # Validations
  validates :first_name, :last_name, :phone, presence: true
  validates :phone, phony_plausible: true, uniqueness: true
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, if: -> { email&.present? }

  def with_existing_record
    # TODO: handle update of existing values except identifiers
    Volunteer.unconfirmed.where(phone: normalized_phone).take || self
  end
end