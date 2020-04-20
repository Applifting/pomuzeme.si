class AddAuthCodeToVolunteer < ActiveRecord::Migration[6.0]
  def change
    add_column :volunteers, :authorization_code, :string
    add_column :volunteers, :authorization_code_valid_to, :datetime
    add_column :volunteers, :authorization_code_attempts, :integer
  end
end
