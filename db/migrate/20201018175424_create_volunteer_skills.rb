class CreateVolunteerSkills < ActiveRecord::Migration[6.0]
  def change
    create_table :volunteer_skills do |t|
      t.references :volunteer, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true

      t.timestamps
    end
  end
end
