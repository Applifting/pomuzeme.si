class CreateVolunteers < ActiveRecord::Migration[6.0]
  def change
    create_table :volunteers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone, null: false
      t.string :street, null: false
      t.string :city, null: false
      t.string :zipcode, null: false

      t.timestamps
    end
  end
end
