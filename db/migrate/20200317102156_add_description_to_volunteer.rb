class AddDescriptionToVolunteer < ActiveRecord::Migration[6.0]
  def change
    add_column :volunteers, :description, :text
  end
end
