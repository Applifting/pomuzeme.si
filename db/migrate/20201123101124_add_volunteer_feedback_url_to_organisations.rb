class AddVolunteerFeedbackUrlToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :volunteer_feedback_message, :string
    add_column :organisations, :volunteer_feedback_send_after_days, :string
  end
end
