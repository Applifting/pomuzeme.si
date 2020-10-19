class CreateVolunteerInterests < ActiveRecord::Migration[6.0]
  def change
    create_table :volunteer_interests do |t|
      t.references :volunteer, null: false, foreign_key: true
      t.references :interest, null: false, foreign_key: true

      t.timestamps
    end
  end
end
