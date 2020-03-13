class AddAttributesToVolunteer < ActiveRecord::Migration[6.0]
  def change
    add_column :volunteers, :email, :string, null: false
    add_column :volunteers, :confirmation_code, :string, length: 6
    add_column :volunteers, :confirmation_valid_to, :datetime
    add_column :volunteers, :confirmed_at, :datetime
  end
end
