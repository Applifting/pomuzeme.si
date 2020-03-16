ActiveAdmin.register Volunteer do
  decorate_with VolunteerDecorator

  index do
    column :full_name
    column :phone
    column :email
    column :confirmed?
    actions if current_user.has_role?(:super_admin)
  end
end
