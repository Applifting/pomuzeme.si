# frozen_string_literal: true

class ExtractAddressFromVolunteer < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'postgis'

    create_table :addresses do |t|
      t.string :street, null: true
      t.string :street_number, null: false
      t.string :city, null: false
      t.string :city_part, null: false
      t.string :geo_entry_id, null: false
      t.string :geo_unit_id, null: false
      t.string :geo_provider, null: false
      t.st_point :coordinate, srid: 4326
      t.string :postal_code, null: true
      t.string :country_code, null: false, limit: 3
      t.references :addressable, polymorphic: true

      t.timestamps
    end

    Volunteer.all.each do |v|
      Address.create!(addressable: v, street: v.street, street_number: v.street_number, city: v.city,
                      city_part: v.city_part, postal_code: v.zipcode, geo_entry_id: v.geo_entry_id, geo_unit_id: v.geo_unit_id,
                      coordinate: Geography::Point.from_s_jtsk(x: v.geo_coord_x, y: v.geo_coord_y), country_code: 'cz',
                      geo_provider: 'cadstudio')
    end

    remove_column :volunteers, :street
    remove_column :volunteers, :street_number
    remove_column :volunteers, :city
    remove_column :volunteers, :city_part
    remove_column :volunteers, :geo_entry_id
    remove_column :volunteers, :geo_unit_id
    remove_column :volunteers, :geo_coord_x
    remove_column :volunteers, :geo_coord_y
    remove_column :volunteers, :zipcode
  end
end
