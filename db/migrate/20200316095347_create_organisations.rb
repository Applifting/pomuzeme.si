class CreateOrganisations < ActiveRecord::Migration[6.0]
  def change
    create_table :organisations do |t|
      t.string :name, null: false
      t.string :abbreviation, null: false
      t.string :business_id_number
      t.string :contact_person, null: false
      t.string :contact_person_phone, null: false
      t.string :contact_person_email, null: false

      t.timestamps
    end
  end
end
