class AddPendingRegistrationToVolunteer < ActiveRecord::Migration[6.0]
  def change
    add_column :volunteers, :pending_registration, :boolean
  end
end
