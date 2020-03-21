ActiveAdmin.register Volunteer do
  decorate_with VolunteerDecorator

  permit_params :description

  # Scopes
  scope :all, default: true
  scope :unconfirmed, if: -> { current_user.admin? }
  scope :confirmed, if: -> { current_user.admin? }

  # Filters
  filter :phone
  filter :street
  filter :city_part
  filter :city
  filter :description

  index do
    id_column
    column :full_name
    column :phone
    column :email
    column :full_address
    column :confirmed? if current_user.admin?
    actions
  end

  show do
    panel resource.full_name do
      attributes_table_for resource do
        row :full_name
        row :phone
        row :email
        row :full_address
        row :description
        row :created_at
        row :updated_at
      end
    end
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
