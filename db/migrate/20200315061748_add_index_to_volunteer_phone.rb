class AddIndexToVolunteerPhone < ActiveRecord::Migration[6.0]
  def change
    add_index :volunteers, :phone
  end
end
