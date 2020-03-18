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

  show do
    modal_window

    panel resource.full_name do
      attributes_table_for resource do
        row :first_name
        row :last_name
        row :email
        row :created_at
        row :updated_at
      end
    end
    panel nil, style: 'width: 580px' do
      render partial: 'roles'
    end
    active_admin_comments
  end

  member_action :new_role, method: :get do
    @user = resource
    @available_roles = Role.includes(:resource).coordinator.for_model(:Organisation).where.not(id: @user.roles.includes(:resource).coordinator.for_model(:Organisation))
    render 'admin/modal/open', locals: { template: 'admin/users/new_role' }
  end

  member_action :create_role, method: :post do
    # TODO: verify cancancan is used here
    role = Role.find_by_id params['role_id']
    user = User.find_by_id params['user_id']
    user.grant role.name, role.resource

    render 'admin/modal/close'
  end

  member_action :destroy_role, method: :post do
    # TODO: verify cancancan is used here
    role = Role.find_by_id params['role_id']
    user = User.find_by_id params['id']
    user.remove_role role.name, role.resource

    render 'admin/modal/close'
  end

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
