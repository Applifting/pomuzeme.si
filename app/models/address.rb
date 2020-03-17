class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validate :location

  private

  def location
    unless street && street_number && city && city_part && geo_entry_id && geo_unit_id && geo_coord_x && geo_coord_y
      errors[:geolocation_err] << ' Prosíme vyberte celou adresu i s číslem popisným'
    end
  end
end