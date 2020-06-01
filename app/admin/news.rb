# frozen_string_literal: true

ActiveAdmin.register News do
  menu parent: 'Admin'

  permit_params :title, :body, :url, :publication_type, :outlet, :created_at

  form do |f|
    f.input :publication_type, include_blank: false
    f.input :title
    f.input :created_at, as: :date_time_picker,
                         hint: I18n.t('activerecord.attributes.news.created_at_hint')
    f.inputs 'Aktuality' do
      f.input :body, as: :text
    end
    f.inputs 'Napsali o nás' do
      f.input :outlet
      f.input :url
    end
    f.actions
  end
end
