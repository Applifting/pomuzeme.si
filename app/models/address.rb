class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true, autosave: true

  enum country_code: { cz: 'cz' }, _suffix: true

  validates_presence_of :street_number, :city, :city_part, :geo_entry_id,
                        :geo_unit_id, :coordinate, :country_code

  after_initialize :initialize_defaults

  private

  def initialize_defaults
    self.country_code = 'cz'
  end
end