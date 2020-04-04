class CreateRequestedVolunteers < ActiveRecord::Migration[6.0]
  def change
    create_table :requested_volunteers do |t|
      t.references :volunteer, null: false, foreign_key: true
      t.references :request, null: false, foreign_key: true
      t.integer :state, null: false, default: 1
      t.datetime :last_notified_at
      t.datetime :last_accepted_at
      t.datetime :last_rejected_at
      t.datetime :last_removed_at

      t.timestamps
    end
  end
end
