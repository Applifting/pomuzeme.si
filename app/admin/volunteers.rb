ActiveAdmin.register Volunteer do
  decorate_with VolunteerDecorator

  permit_params :description, :first_name, :last_name, :phone, :email

  scope :all, default: true do |scope|
    current_user.admin? ?  scope : scope.available_for(current_user.organisation_group.id)
  end
  scope :unconfirmed, if: -> { current_user.admin? }
  scope :confirmed, if: -> { current_user.admin? }

  # Filters
  filter :full_name_cont, label: 'Jméno / příjmení'
  filter :has_labels, label: 'Štítky',
         as: :select, multiple: true,
         collection: proc { OptionsWrapper.wrap (Label.managable_by(current_user).map { |i| [i.name, i.id] }), params, :has_labels },
         selected: 1,
         input_html: { style: 'height: 100px' }
  filter :phone
  filter :email
  filter :search_nearby, as: :hidden, label: 'Location'
  filter :address_search_input, as: :address_search, label: 'Vzdálenost od adresy'

  # Batch actions
  config.batch_actions = true
  # Form args has to be inside lambda due to calling of current_user
  form_lambda = -> { { request: current_user.coordinator_organisation_requests.assignable.collect { |request| [request.title, request.id] } } }

  batch_action :assign_request, form: form_lambda do |ids, inputs|
    request = Request.find(inputs[:request])
    Admin::Requests::VolunteerAssigner.new(current_user, request, Volunteer.where(id: ids)).perform
    redirect_to admin_organisation_request_path request
  rescue StandardError => e
    redirect_to admin_volunteers_path, alert: e.message
  end

  index do
    javascript_for(*location_autocomplete(callback: 'InitFilterAutocomplete'))

    selectable_column
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

    panel nil, style: 'width: 580px' do
      render partial: 'recruitment'
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
