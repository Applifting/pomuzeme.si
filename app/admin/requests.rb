# frozen_string_literal: true

ActiveAdmin.register Request do
  decorate_with RequestDecorator

  scope_to :current_user, association_method: :coordinator_organisation_requests, unless: -> { current_user.admin? }

  config.sort_order = 'state_asc'

  filter :text
  filter :required_volunteer_count
  filter :state, as: :select, collection: Request.states

  index do
    id_column
    column :text
    column :required_volunteer_count
    column :fullfilment_date
    column :coordinator
    column :state
    column :state_last_updated_at
  end
end
