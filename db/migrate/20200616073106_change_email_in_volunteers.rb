class ChangeEmailInVolunteers < ActiveRecord::Migration[6.0]
  def change
    change_column :volunteers, :email, :string, null: true
  end
end
