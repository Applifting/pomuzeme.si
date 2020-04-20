class AddVisibleSensitiveToRequestedVolunteer < ActiveRecord::Migration[6.0]
  def change
    add_column :requested_volunteers, :visible_sensitive, :boolean, default: false
  end
end
