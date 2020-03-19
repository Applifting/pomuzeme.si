# frozen_string_literal: true

ActiveAdmin.register Group do
  permit_params :name, :slug, :channel_description, :thank_you

  show do
    modal_window

    panel resource.name do
      attributes_table_for resource do
        row :name
        row :slug
        row :created_at
        row :updated_at
      end
    end
    panel nil, style: 'width: 580px' do
      render partial: 'organisations'
      render partial: 'labels'
    end
    active_admin_comments
  end
end
