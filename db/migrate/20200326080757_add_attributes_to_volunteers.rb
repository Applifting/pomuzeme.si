class AddAttributesToVolunteers < ActiveRecord::Migration[6.0]
  def change
    add_column :volunteers, :fcm_token, :string
    add_column :volunteers, :preferences, :jsonb
  end
end
