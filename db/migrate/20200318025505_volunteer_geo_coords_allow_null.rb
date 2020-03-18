class VolunteerGeoCoordsAllowNull < ActiveRecord::Migration[6.0]
  def change
    change_column :volunteers, :geo_coord_x, :float, null: true
    change_column :volunteers, :geo_coord_y, :float, null: true
  end
end
