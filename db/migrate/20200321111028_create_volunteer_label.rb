class CreateVolunteerLabel < ActiveRecord::Migration[6.0]
  def change
    create_table :volunteer_labels do |t|
      t.references :volunteer, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
    end
  end
end
