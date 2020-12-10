# frozen_string_literal: true

ActiveAdmin.register Group do
  decorate_with GroupDecorator

  permit_params :name, :slug, :channel_description, :thank_you, :exclusive_volunteer_signup,
                :signup_cta_button_text, :signup_tagline_text, :signup_partial_name

  index do
    para 'Organizační skupina zastřešuje vaše místní organizace, které mezi sebou sdílí dobrovolníky.'
    para 'Do skupiny jsou napojeni dobrovolníci, kteří se zaregistrovali přes link vaší organizace (např. pomuzeme.si/diecezni-charita-ceske-budejovice).'

    id_column
    column :name
    column :slug
    column :created_at
    column :updated_at
    actions
  end

  show do
    modal_window

    panel resource.name do
      attributes_table_for resource do
        row :name
        row :slug
        row :exclusive_volunteer_signup
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
