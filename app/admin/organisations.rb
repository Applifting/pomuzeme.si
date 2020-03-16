ActiveAdmin.register Organisation do

  menu if: -> { can? :read, Organisation }

  decorate_with OrganisationDecorator

  index do
    column :name
    column :abbrevation
    column :business_id_number
    column :contact_person
    column :contact_person_phone
    column :contact_person_email
    column :created_at
    column :updated_at
    actions if current_user.has_role?(:super_admin) # TODO: move to helper method
  end


end
