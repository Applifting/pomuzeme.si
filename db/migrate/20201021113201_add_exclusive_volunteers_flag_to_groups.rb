class AddExclusiveVolunteersFlagToGroups < ActiveRecord::Migration[6.0]
  def change
    # Indicates if volunteer sign-ed up through group url is exclusive or not
    add_column :groups, :exclusive_volunteer_signup, :boolean, default: true
  end
end
