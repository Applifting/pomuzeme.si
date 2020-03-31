ActiveAdmin.register Address do
  menu false

  actions :all, except: %i[destroy new create]

  decorate_with AddressDecorator

  permit_params :id, :street_number, :street, :city, :city_part, :postal_code, :country_code,
                :latitude, :longitude, :geo_entry_id, :addressable_type, :addressable_id

  filter :street_number
  filter :street
  filter :city
  filter :city_part
  filter :postal_code
  filter :search_nearby, as: :hidden, label: 'Location'
  filter :address_search_input, as: :address_search

  index do
    javascript_for(*location_autocomplete(callback: 'InitFilterAutocomplete'))

    id_column
    column :full_address
    if params[:q] && params[:q][:search_nearby]
      params[:order] = 'distance_meters_asc'

      # we'll alias this column to `distance_meters` in our scope so it can be sorted by
      column :distance, sortable: 'distance_meters', &:distance_in_km
    end

    if current_user.admin?
      column :created_at
      column :updated_at
    end
    actions
  end

  show do
    panel resource do
      attributes_table_for resource do
        row :id
        row :street
        row :street_number
        row :city
        row :city_part
        row :geo_entry_id
        row :geo_unit_id
        row :geo_provider
        row :latitude
        row :longitude
        row :postal_code
        row :country_code
        row :addressable_type
        row :addressable_id
        row :created_at
        row :updated_at
      end
    end

    active_admin_comments
  end

  form do |f|
    javascript_for(*location_autocomplete)

    f.inputs 'Aktualizace adresy' do
      f.semantic_errors
      f.input :id, as: :hidden
      custom_input :full_address, label: I18n.t('activerecord.attributes.address.new_address'),
                                  class: 'geocomplete',
                                  hint: I18n.t('activerecord.attributes.address.current_address', address: resource)
      f.input :street_number, as: :hidden
      f.input :street, as: :hidden
      f.input :city, as: :hidden
      f.input :city_part, as: :hidden
      f.input :postal_code, as: :hidden
      f.input :country_code, as: :hidden
      f.input :latitude, as: :hidden
      f.input :longitude, as: :hidden
      f.input :geo_entry_id, as: :hidden
      custom_input :redirect_to, type: :hidden, value: request.referrer
      if current_user.admin?
        f.inputs 'Super admin' do
          f.input :addressable_type
          f.input :addressable_id
        end
      end
    end
    f.actions
  end

  controller do
    def update
      @resource = AddressForm.build(permitted_params[:address])

      if @resource.save
        original_referrer = params[:address][:redirect_to]
        redirect = original_referrer && URI(original_referrer).path || admin_address_path(@resource)
        redirect_to redirect, notice: I18n.t('activerecord.attributes.address.updated')
      else
        puts @resource.errors.messages
        @resource.errors.add :base, I18n.t('activerecord.errors.models.address.base.inaccurate_address')
        render :edit, notice: @resource.errors.messages
      end
    end
  end
end
