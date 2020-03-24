# frozen_string_literal: true

ActiveAdmin.register Request, as: 'OrganisationRequest' do
  decorate_with RequestDecorator
  config.sort_order = 'state_asc'

  menu priority: 2

  scope_to :current_user, association_method: :coordinator_organisation_requests, unless: -> { current_user.admin? }

  permit_params :closed_note, :coordinator_id, :created_by_id, :fullfillment_date, :organisation_id,
                :required_volunteer_count, :state, :subscriber, :subscriber_phone, :text

  # Filters
  filter :text
  filter :required_volunteer_count
  filter :state, as: :select, collection: Request.states

  index do
    id_column
    column :state
    column :text
    column :accepted_volunteers_count do |resource|
      "#{resource.requested_volunteers.accepted.count} / #{resource.required_volunteer_count}"
    end
    column :fullfillment_date
    column :coordinator
    column :state_last_updated_at
    column :organisation if current_user.admin?
    actions
  end

  show do
    panel resource.text do
      attributes_table_for resource do
        row :id
        row :text
        row :required_volunteer_count
        row :fullfillment_date
        row :coordinator
        row :state
        row :state_last_updated_at
      end
    end
    panel nil, style: 'width: 580px' do
      render partial: 'volunteers'
    end
    active_admin_comments
  end

  form do |f|
    f.inputs 'Poptávka' do
      f.input :text, as: :text
      f.input :required_volunteer_count
      f.input :subscriber
      f.input :subscriber_phone, input_html: { maxlength: 13 }
    end
    f.inputs 'Koordinace' do
      f.input :state if resource.persisted?
      f.input :organisation, as: :select,
                             collection: Organisation.where(id: current_user.coordinating_organisations.pluck(:id)),
                             include_blank: false
      f.input :fullfillment_date, as: :datetime_picker
      f.input :coordinator_id, as: :select, collection: current_user.organisation_colleagues
      f.input :closed_note, as: :text if resource.persisted?
      f.input :created_by_id, as: :hidden, input_html: { value: current_user.id }
    end
    f.actions
  end
end
