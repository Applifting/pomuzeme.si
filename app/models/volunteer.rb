class Volunteer < ApplicationRecord
  include SmsConfirmable

  # Associations
  has_many :group_volunteers
  has_many :groups, through: :group_volunteers

  # normalize phone format and add default czech prefix if missings
  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'

  validates :first_name, :last_name, :phone, presence: true
  validates :phone, phony_plausible: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email&.present? }
  validate :location

  after_commit :invalidate_volunteer_count_cache

  def with_existing_record
    Volunteer.unconfirmed.where(phone: normalized_phone).take || self
  end

  private

  def location
    return if street && street_number && city && city_part && geo_entry_id && geo_unit_id && geo_coord_x && geo_coord_y

    errors[:geolocation_err] << ' Prosíme vyberte celou adresu i s číslem popisným'
  end

  def invalidate_volunteer_count_cache
    Rails.cache.delete :volunteer_count
  end
end
