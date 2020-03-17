ActiveAdmin.register Volunteer do

  decorate_with VolunteerDecorator

  scope :all, default: true
  scope :unconfirmed, if: -> { current_user.admin? }
  scope :confirmed, if: -> { current_user.admin? }

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
