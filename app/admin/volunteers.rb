ActiveAdmin.register Volunteer do
  decorate_with VolunteerDecorator

  permit_params :description, :first_name, :last_name, :phone, :email,
                addresses_attributes: %i[street_number street city city_part postal_code country_code
                                         latitude longitude geo_entry_id]

  scope :volunteer_verified, default: true do |scope|
    scope.verified_by(current_user.organisation_group.id)
  end
  scope :volunteer_public do |scope|
    scope.not_recruited_by(current_user.organisation_group.id)
  end
  # scope
  scope :volunteer_all, default: true do |scope|
    current_user.cached_admin? ? scope : scope.available_for(current_user.organisation_group.id)
  end
  scope :unconfirmed, if: -> { current_user.cached_admin? }
  scope :confirmed, if: -> { current_user.cached_admin? }

  # Filters
  filter :full_name_cont, label: 'Jméno / příjmení'
  filter :has_labels, label: 'Štítky',
                      as: :select, multiple: true,
                      collection: proc { OptionsWrapper.wrap (Label.alphabetically.managable_by(current_user).map { |i| [i.name, i.id] }), params, :has_labels },
                      selected: 1,
                      input_html: { style: 'height: 100px' }
  filter :has_interests, label: 'Zájmy v dobrovolnictví',
                      as: :select,
                      collection: proc { OptionsWrapper.wrap (Interest.alphabetically.map { |i| [i.name, i.id] }), params, :has_interests },
                      selected: 1
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
    results = Admin::Requests::VolunteerAssigner.new(current_user, request, Volunteer.where(id: ids)).perform

    flash[:notice] = "Počet přiřazených dobrovolníků: #{ids.count - results.count}"
    flash[:error] = "Některé dobrovolníky se nepodařilo k poptávce přiřadit (#{results.map { |v| v.to_s }.join(', ')})." if results.present?
    redirect_to admin_organisation_request_path request.id
  rescue StandardError => e
    redirect_to admin_organisation_request_path(request.id), alert: e.message
  end

  controller do
    include ActiveAdmin::VolunteersHelper

    def scoped_collection
      scoped_request ? super.not_blocked.where.not(id: Volunteer.assigned_to_request(scoped_request.id)) : super
    end

    def create
      super do |success, failure|
        success.html do
          resource.process_manual_registration current_user
          redirect_to admin_volunteer_path(resource), notice: "Dobrovolník uložen, zkontrolujte stav náboru."
        end
        failure.html { render :new }
      end
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
      resource.show_contact_details?(current_user, params) ? resource.phone : 'v detailu'
    end
    column :email do |resource|
      resource.show_contact_details?(current_user, params) ? resource.email : 'v detailu'
    end
    if params[:q] && params[:q][:search_nearby]
      params[:order] = 'distance_meters_asc'

      column :address do |resource|
        resource.addresses.detect { |address| address.id == resource.distance_address_id }
      end

      # we'll alias this column to `distance_meters` in our scope so it can be sorted by
      column :distance, sortable: 'distance_meters' do |resource|
        resource.address.distance_in_km(resource.distance_meters)
      end
    else
      column :address
    end
    column :confirmed? if current_user.cached_admin?
    actions
  end

  show do
    panel resource.full_name do
      tabs do
        tab 'Profil' do
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

        tab 'Preference' do
          para 'Zájmy'
          attributes_table_for resource.interests do
            row :name, 'Název'
          end

          para 'Dovednosti'
          attributes_table_for resource.skills do
            row :name
          end
        end if resource.interests.present? || resource.skills.present?
      end
    end

    panel nil, style: 'width: 580px' do
      render partial: 'recruitment'
      render partial: 'labels'
      render partial: 'requests'
    end
  end

  form do |f|
    javascript_for(*location_autocomplete(callback: 'InitVolunteerAutocomplete'))

    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :phone
      f.input :email
      address_label = proc { |type| I18n.t("activerecord.attributes.volunteer.#{type}") }
      custom_input :full_address, class: 'geocomplete',
                                  label: (address_label['full_address'] + ' *')

      f.inputs for: [:addresses, f.object.addresses.first || f.object.addresses.build] do |address_form|
        address_form.input :street_number, as: :hidden
        address_form.input :street, as: :hidden
        address_form.input :city, as: :hidden
        address_form.input :city_part, as: :hidden
        address_form.input :postal_code, as: :hidden
        address_form.input :country_code, as: :hidden
        address_form.input :latitude, as: :hidden
        address_form.input :longitude, as: :hidden
        address_form.input :geo_entry_id, as: :hidden
      end
      f.inputs :description, as: :text
      f.inputs(:preferences, as: :jsonb) if current_user.admin?
    end
    f.actions
  end

  csv do
    column :first_name
    column :last_name
    column :phone do |resource|
      resource.show_contact_details?(current_user, params) ? resource.phone : 'v detailu'
    end
    column :email do |resource|
      resource.show_contact_details?(current_user, params) ? resource.email : 'v detailu'
    end
    column :street
    column :city
  end
end
