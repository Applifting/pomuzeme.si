ActiveAdmin.register Volunteer do
  decorate_with VolunteerDecorator

  permit_params :description, :first_name, :last_name, :phone, :email

  scope :volunteer_verified, default: true do |scope|
    scope.verified_by(current_user.organisation_group.id)
  end
  scope :volunteer_public do |scope|
    scope.not_recruited_by(current_user.organisation_group.id)
  end
  # scope
  scope :volunteer_all, default: true do |scope|
    current_user.admin? ? scope : scope.available_for(current_user.organisation_group.id)
  end
  scope :unconfirmed, if: -> { current_user.admin? }
  scope :confirmed, if: -> { current_user.admin? }

  # Filters
  filter :full_name_cont, label: 'Jméno / příjmení'
  filter :has_labels, label: 'Štítky',
                      as: :select, multiple: true,
                      collection: proc { OptionsWrapper.wrap (Label.alphabetically.managable_by(current_user).map { |i| [i.name, i.id] }), params, :has_labels },
                      selected: 1,
                      input_html: { style: 'height: 100px' }
  filter :phone_or_email_cont, label: 'Telefon / email'
  filter :group_volunteers_coordinator_id_eq, as: :select,
                                              collection: proc { OptionsWrapper.wrap (current_user.organisation_colleagues.map { |i| [i.to_s, i.id] }), params, :group_volunteer_coordinator_eq },
                                              label: 'Koordinátor dobrovolníka'
  filter :search_nearby, as: :hidden, label: 'Location'
  filter :address_search_input, as: :address_search, label: 'Vzdálenost od adresy'

  # Batch actions
  config.batch_actions = true
  # Form args has to be inside lambda due to calling of current_user

  batch_action :assign_request, confirm: I18n.t('active_admin.batch_actions.assign_request.confirmation') do |ids|
    request = referer_request
    Admin::Requests::VolunteerAssigner.new(current_user, request, Volunteer.where(id: ids)).perform
    redirect_to admin_organisation_request_path request.id
  rescue StandardError => e
    redirect_to admin_organisation_request_path(request.id), alert: e.message
  end

  controller do
    include ActiveAdmin::VolunteersHelper

    def scoped_collection
      scoped_request ? super.not_blocked.where.not(id: Volunteer.assigned_to_request(scoped_request.id)) : super
    end
  end

  index do
    javascript_for(*location_autocomplete(callback: 'InitFilterAutocomplete'))

    if scoped_request
      para I18n.t('active_admin.batch_actions.assign_request.title', request: scoped_request.title)
      para I18n.t('active_admin.batch_actions.assign_request.description'), class: :small
      selectable_column
    end
    id_column
    column :full_name
    column :phone do |resource|
      resource.show_contact_details?(params) ? resource.phone : 'v detailu'
    end
    column :email do |resource|
      resource.show_contact_details?(params) ? resource.email : 'v detailu'
    end
    column :address
    if params[:q] && params[:q][:search_nearby]
      params[:order] = 'distance_meters_asc'

      # we'll alias this column to `distance_meters` in our scope so it can be sorted by
      column :distance, sortable: 'distance_meters' do |resource|
        resource.address.distance_in_km(resource.distance_meters)
      end
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
        row :address, &:address_link
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

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :phone
      f.input :email
      f.input :description
    end
    f.actions
  end

  csv do
    column :first_name
    column :last_name
    column :phone do |resource|
      resource.show_contact_details?(params) ? resource.phone : 'v detailu'
    end
    column :email do |resource|
      resource.show_contact_details?(params) ? resource.email : 'v detailu'
    end
    column :street
    column :city
  end
end
