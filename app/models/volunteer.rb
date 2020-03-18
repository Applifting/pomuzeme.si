class Volunteer < ApplicationRecord
  include SmsConfirmable

  # normalize phone format and add default czech prefix if missings
  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'

  validates :first_name, :last_name, :phone, presence: true
  validates :phone, phony_plausible: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email&.present? }
  validate :location

  def with_existing_record
    # TODO: handle update of existing values except identifiers
    Volunteer.unconfirmed.where(phone: normalized_phone).take || self
  end

  private

  def location
    return if street && street_number && city && city_part && geo_entry_id && geo_unit_id

    errors[:geolocation_err] << ' Prosíme vyberte celou adresu i s číslem popisným'
  end
end
