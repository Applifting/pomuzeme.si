class ExtractAddressFromVolunteer < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.string :street, null: false
      t.string :street_number, null: false
      t.string :city, null: false
      t.string :city_part, null: false
      t.string :geo_entry_id, null: false
      t.string :geo_unit_id, null: false
      t.string :geo_coord_x, null: false
      t.string :geo_coord_y, null: false
      t.string :postal_code, null: true
      t.string :country_code, null: false
      t.references :addressable, polymorphic: true

      t.timestamps
    end

    Volunteer.all.each do |v|
      Address.create!(addressable: v, street: v.street, street_number: v.street_number, city: v.city,
                                city_part: v.city_part, geo_entry_id: v.geo_entry_id, geo_unit_id: v.geo_unit_id,
                                geo_coord_x: v.geo_coord_x, geo_coord_y: v.geo_coord_y, country_code: 'cz'
      )
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
