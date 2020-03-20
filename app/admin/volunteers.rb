ActiveAdmin.register Volunteer do
  decorate_with VolunteerDecorator

  # Scopes
  scope :all, default: true
  scope :unconfirmed, if: -> { current_user.admin? }
  scope :confirmed, if: -> { current_user.admin? }

  # Filters
  filter :first_name
  filter :last_name
  filter :phone
  filter :email
  filter :search_nearby, as: :hidden, label: 'Location'
  filter :address_search_input, as: :address_search

  index do
    javascript_for(*location_autocomplete(callback: 'InitFilterAutocomplete'))

    id_column
    column :full_name
    column :phone
    column :email
    if params[:q] && params[:q][:search_nearby]
      params[:order] = 'distance_meters_asc'

      # we'll alias this column to `distance_meters` in our scope so it can be sorted by
      column :distance, sortable: 'distance_meters', &:distance_in_km
    end
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
