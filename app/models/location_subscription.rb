# frozen_string_literal: true

class LocationSubscription < ApplicationRecord
  # Associations
  has_one :address, as: :addressable, dependent: :destroy

  # Validations
  validates :phone, phony_plausible: true, presence: true

  # Attributes
  accepts_nested_attributes_for :address

  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'
end
