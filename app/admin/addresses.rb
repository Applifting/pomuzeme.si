ActiveAdmin.register Address do

  actions :all, :except => [:edit, :destroy, :new]

  decorate_with AddressDecorator

  index do
    id_column
    column :full_address
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
