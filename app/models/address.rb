# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true, autosave: true

  enum country_code: { cz: 'CZ' }, _suffix: true

  validates_presence_of :street, :street_number, :city, :city_part, :geo_entry_id,
                        :geo_unit_id, :geo_cord, :postal_code, :country_code
end
