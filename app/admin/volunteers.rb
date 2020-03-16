ActiveAdmin.register Volunteer do
  decorate_with VolunteerDecorator

  index do
    id_column
    column :full_name
    column :phone
    column :email
    column :street
    column :city
    if current_user.admin?
      column :confirmed?
    end
    actions
  end

  csv do
    column :first_name
    column :last_name
    column :phone
    column :email
    column :street
    column :city
  end
end
