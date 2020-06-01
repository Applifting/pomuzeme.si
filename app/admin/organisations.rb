# frozen_string_literal: true

ActiveAdmin.register Organisation do
  decorate_with OrganisationDecorator

  permit_params :name, :abbreviation, :business_id_number, :contact_person, :contact_person_email, :contact_person_phone

  index do
    para 'Organizace ve vaší organizační skupině', class: :small

    id_column
    column :name
    column :abbreviation
    column :business_id_number
    if current_user.cached_admin?
      column :created_at
      column :updated_at
    end
    actions
  end
end
