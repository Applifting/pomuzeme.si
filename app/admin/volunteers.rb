ActiveAdmin.register Volunteer do
  decorate_with VolunteerDecorator

  # Scopes
  scope :all, default: true
  scope :unconfirmed, if: -> { current_user.admin? }
  scope :confirmed, if: -> { current_user.admin? }

  # Filters
  filter :phone
  filter :street
  filter :city_part
  filter :city

  index do
    id_column
    column :full_name
    column :phone
    column :email
    column :street
    column :city
    column :city_part
    column :confirmed? if current_user.admin?
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
