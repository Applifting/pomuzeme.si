# frozen_string_literal: true

ActiveAdmin.register Organisation do
  decorate_with OrganisationDecorator

  permit_params :abbreviation, :business_id_number, :contact_person, :contact_person_email, :contact_person_phone,
                :name, :volunteer_feedback_message, :volunteer_feedback_send_after_days

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

  form do |f|
    f.inputs 'Organizace' do
      f.input :name
      f.input :abbreviation
      f.input :business_id_number
      f.input :contact_person
      f.input :contact_person_phone
      f.input :contact_person_email
    end
    f.inputs 'Zpětná vazba od potvrzených dobrovolníků' do
      f.input :volunteer_feedback_message, as: :text, hint: i18n_model_attribute(resource, :volunteer_feedback_message_hint)
      f.input :volunteer_feedback_send_after_days, as: :number, hint: i18n_model_attribute(resource, :volunteer_feedback_send_after_days_hint)
    end
    f.actions
  end
end
