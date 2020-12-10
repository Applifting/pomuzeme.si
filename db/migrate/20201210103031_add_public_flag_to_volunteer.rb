class AddPublicFlagToVolunteer < ActiveRecord::Migration[6.0]
  def change
    add_column :volunteers, :is_public, :boolean, null: true, default: true

    reversible do |dir|
      dir.up do
        Volunteer.joins(:group_volunteers).merge(GroupVolunteer.exclusive).update_all(is_public: false)
      end
    end
  end
end
