class AddUniqueIndexToRequestedVolunteer < ActiveRecord::Migration[6.0]
  def change
    add_index :requested_volunteers, [:request_id, :volunteer_id], unique: true
  end
end
