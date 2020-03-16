ActiveAdmin.register Organisation do
  decorate_with OrganisationDecorator

  scope_to :current_user, association_method: :coordinating_organisations, unless: -> { current_user.admin? }

  permit_params :name, :abbreviation, :business_id_number, :contact_person, :contact_person_email, :contact_person_phone

  index do
    id_column
    column :name
    column :abbreviation
    column :business_id_number
    if current_user.admin?
      column :created_at
      column :updated_at
    end
    actions
  end
end
