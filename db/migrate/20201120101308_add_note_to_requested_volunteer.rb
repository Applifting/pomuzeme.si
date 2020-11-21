class AddNoteToRequestedVolunteer < ActiveRecord::Migration[6.0]
  def change
    add_column :requested_volunteers, :note, :string
  end
end
