class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.references :addressable, null: false, polymorphic: true
      t.string :street, null: false
      t.string :street_number, null: false
      t.string :city, null: false
      t.string :city_part, null: false
      t.string :geo_entry_id, null: false
      t.string :geo_unit_id, null: false
      t.st_point :geo_cord, null: false
      t.string :postal_code, null: false
      t.string :country_code, null: false, limit: 2

      t.timestamps
    end
  end
end
