ActiveAdmin.register Address do

  decorate_with AddressDecorator

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :street, :street_number, :city, :city_part, :geo_entry_id, :geo_unit_id, :coordinate, :postal_code, :country_code, :addressable_type, :addressable_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:street, :street_number, :city, :city_part, :geo_entry_id, :geo_unit_id, :coordinate, :postal_code, :country_code, :addressable_type, :addressable_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  show do
    modal_window

    panel resource do
      attributes_table_for resource do
        row :id
        row :street
        row :street_number
        row :city
        row :city_part
        row :geo_entry_id
        row :geo_unit_id
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
    panel nil, style: 'width: 580px' do
    end
    active_admin_comments
  end
end
