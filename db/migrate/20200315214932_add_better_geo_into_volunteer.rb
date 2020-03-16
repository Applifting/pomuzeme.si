class AddBetterGeoIntoVolunteer < ActiveRecord::Migration[6.0]
  def change
    change_column_null :volunteers, :zipcode, true
    add_column :volunteers, :street_number, :string, null: false
    add_column :volunteers, :city_part, :string, null: false
    add_column :volunteers, :geo_entry_id, :string, null: false
    add_column :volunteers, :geo_unit_id, :string, null: false
    add_column :volunteers, :geo_coord_x, :float, null: false
    add_column :volunteers, :geo_coord_y, :float, null: false
  end
end
