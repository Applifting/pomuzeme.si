# frozen_string_literal: true

ActiveAdmin.register User do
  decorate_with UserDecorator

  permit_params :email, :password, :password_confirmation, :first_name, :last_name

  index do
    id_column
    column :first_name
    column :last_name
    column :email
    if current_user.admin?
      column :created_at
      column :updated_at
    end
    actions
  end

  # TODO: add possibility to assign coordinator role on show page

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
