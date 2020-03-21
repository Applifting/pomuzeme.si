ActiveAdmin.register Volunteer do
  decorate_with VolunteerDecorator

  permit_params :description

  # Scopes
  # TODO: fix preloading
  # scope 'all', default: true do |_scope|
  #   Volunteer.preload(:addresses)
  # end
  scope :all, default: true
  scope :unconfirmed, if: -> { current_user.admin? }
  scope :confirmed, if: -> { current_user.admin? }

  # Filters
  filter :first_name
  filter :last_name
  filter :volunteer_labels_label_id_in_all, label: 'Štítky',
                                            as: :select, multiple: true,
                                            collection: proc { OptionsHelper.wrap (Label.where(group_id: current_user.coordinating_groups).map { |i| [i.name, i.id] }), params, :volunteer_labels_label_id_in_all },
                                            selected: 1,
                                            input_html: { style: 'height: 100px' }
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
    column :full_address
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

    panel nil, style: 'width: 580px' do
      render partial: 'labels'
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
