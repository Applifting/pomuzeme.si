# frozen_string_literal: true

ActiveAdmin.register Request do
  decorate_with RequestDecorator

  permit_params :text, :required_volunteer_count, :subscriber, :subscriber_phone, :coordinator, :organisation,
                :status, :fulfillment_date, :closed_note, :closed_at, :closed_status, :closed_by, :is_published,
                address_attributes: %i[street street_number city city_part geo_entry_id geo_unit_id latitude
                                       longitude postal_code country_code]

  scope :all, default: true
  scope :only_public, if: -> { current_user.admin? }
  scope :only_private, if: -> { current_user.admin? }

  index do
    id_column
    column :text
    column :status
    column :organisation
    column :fulfillment_date
    column :is_published
    if current_user.admin?
      column :created_at
      column :updated_at
    end
    actions
  end

  show do
    panel resource do
      attributes_table_for resource do
        row :text
        row :required_volunteer_count
        row :subscriber
        row :subscriber_phone
        row :coordinator
        row :organisation
        row :fulfillment_date
        row :is_published
        panel resource.address do
          attributes_table_for resource.address do
            row :id
            row :street
            row :street_number
            row :city
            row :city_part
            row :geo_entry_id
            row :geo_unit_id
            row :postal_code
            row :country_code
          end
        end
      end
    end
    panel nil, style: 'width: 580px' do
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :text
      f.input :required_volunteer_count
      f.input :subscriber
      f.input :subscriber_phone
      f.input :coordinator
      f.input :organisation
      f.input :fulfillment_date
      f.has_many :address do |a|
        a.input :street
        a.input :street_number
        a.input :city
        a.input :city_part
        a.input :geo_entry_id
        a.input :geo_unit_id
        a.input :postal_code
        a.input :country_code
      end
      f.input :is_published
    end
    f.actions
  end
end
