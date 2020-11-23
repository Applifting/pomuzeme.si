class AddVolunteerFeedbackAttributesToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :volunteer_feedback_message, :string, default: nil
    add_column :organisations, :volunteer_feedback_send_after_days, :integer
  end
end
