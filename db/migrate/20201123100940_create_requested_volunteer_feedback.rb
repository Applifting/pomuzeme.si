class CreateRequestedVolunteerFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :requested_volunteer_feedbacks do |t|
      t.references :requested_volunteer, null: false, foreign_key: true
      t.timestamps
    end
  end
end
