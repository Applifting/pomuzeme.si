# frozen_string_literal: true

ActiveAdmin.register Request, as: 'OrganisationRequest' do
  decorate_with RequestDecorator
  config.sort_order = 'state_asc'

  menu priority: 2

  permit_params :closed_note, :coordinator_id, :created_by_id, :fullfillment_date, :is_public,
                :organisation_id, :required_volunteer_count, :state, :subscriber, :subscriber_organisation,
                :subscriber_phone, :subscriber_email, :text, :long_text, :block_volunteer_until, :follow_up_after,
                address_attributes: %i[street_number street city city_part postal_code country_code
                                       latitude longitude geo_entry_id]

  # Filters
  filter :coordinator, collection: proc { OptionsWrapper.wrap (current_user.organisation_colleagues.map { |i| [i.to_s, i.id] }), params, :coordinator_id_eq }
  filter :text_cont, label: 'Text poptávky'
  filter :subscriber_or_subscriber_organisation_cont, label: 'Příjemce poptávky'
  filter :state, as: :select, collection: Request.states
  filter :organisation, as: :select, collection: proc { Organisation.user_group_organisations(current_user) }

  # Scopes
  scope :request_unread_msgs do |scope|
    scope.not_closed.has_unread_messages
  end
  scope :request_in_preparation, default: true do |scope|
    scope.assignable
         .with_organisations(current_user.coordinating_organisations.pluck(:id))
  end
  scope :request_in_fulfillment do |scope|
    scope.in_progress
         .with_organisations(current_user.coordinating_organisations.pluck(:id))
  end
  scope :request_for_followup do |scope|
    scope.for_followup
         .with_organisations(current_user.coordinating_organisations.pluck(:id))
  end
  scope :closed
  scope :all

  # Controller
  controller do
    def update
      super do |success, _failure|
        notify_volunteers_updated if success.present?
      end
    end

    def scoped_collection
      super.includes(:address, :coordinator, :organisation)
    end

    private

    def notify_volunteers_updated
      Admin::Requests::VolunteerNotifier.new(current_user, resource).notify_updated
    end
  end

  # Custom controller actions
  member_action :remove_followup, method: :post do
    resource = Request.find(params[:id])
    resource.update follow_up_after: nil
    redirect_to admin_organisation_request_path(resource)
  end

  member_action :notify_volunteers, method: :post do
    Admin::Requests::VolunteerNotifier.new(current_user, resource).notify_assigned
    flash[:notice] = 'Dobrovolníci osloveni'
    redirect_to admin_organisation_request_path(resource)
  end

  # Action items
  action_item :cancel_followup, only: %i(show) do
    if resource.follow_up_after.present?
      link_to 'Zrušit follow-up', remove_followup_admin_organisation_request_path(resource), method: :post,
                                                                                             style: 'background-color: gray'
    end
  end

  index do
    id_column
    column :state
    column :subscriber, :subscriber_with_unread_status
    column :text
    column :accepted_volunteers_count do |resource|
      "#{resource.requested_volunteers.accepted.count} / #{resource.required_volunteer_count}"
    end
    column :requested_volunteers do |resource|
      resource.requested_volunteers.count
    end
    column :address
    column :fullfillment_date
    column :coordinator
    column :state_last_updated_at
    column :organisation
    actions
  end

  show do
    div style: 'width: 680px' do
      panel resource.text do
        attributes_table_for resource do
          row :address, &:address_link
          row :fullfillment_date
        end
      end
      panel 'Osobní údaje' do
        if can?(:manage, resource)
          attributes_table_for resource do
            row :subscriber
            row :subscriber_phone_and_messages
            row :subscriber_email
            row :long_text
          end
        else
          para 'Tyto údaje může zobrazit pouze koordinátor organizace, která poptávku spravuje.', class: :small
        end
      end
      panel '' do
        attributes_table_for resource do
          row :state do |request|
            if can?(:update, resource)
              best_in_place request, :state, as: :select,
                                             collection: I18n.t('activerecord.attributes.request.states'),
                                             url: admin_organisation_request_path(resource)
            else
              status_tag I18n.t(resource.state, scope: 'activerecord.attributes.request.states')
            end
          end
          row :coordinator do
            if can?(:update, resource)
              best_in_place resource, :coordinator_id, as: :select,
                                                       collection: current_user.organisation_colleagues.map { |u| [u.id, u.to_s] },
                                                       url: admin_organisation_request_path(resource)
            else
              resource.coordinator
            end
          end
          row :required_volunteer_count
          row :block_volunteer_until
          row :state_last_updated_at
          row :created_at
          row :creator
          row :organisation
          row :is_public
        end
      end
      panel nil do
        render partial: 'volunteers' if can?(:manage, resource)
      end
    end
    active_admin_comments
  end

  form do |f|
    javascript_for(*location_autocomplete(callback: 'InitRequestAutocomplete'))

    f.semantic_errors

    f.inputs 'Poptávka služby' do
      f.input :text, as: :text, hint: 'Tento popis dostane dobrovolník do aplikace / SMS.', input_html: { class: :character_counter, 'data-limit' => 160 }
      f.input :required_volunteer_count, input_html: { value: object.required_volunteer_count.nil? ? 1 : resource.required_volunteer_count }
      f.input :fullfillment_date, as: :date_time_picker, input_html: { autocomplete: 'off' }
    end

    f.inputs 'Údaje příjemce' do
      para 'K osobním údajům příjemce služby se dostanou pouze koordinátoři vaší organizace.', class: :small
      f.input :subscriber
      f.input :subscriber_organisation
      f.input :subscriber_phone, input_html: { maxlength: 13, value: (object.subscriber_phone || '+420') },
                                 hint: 'Je-li příjemce organizace, dostane po přijetí poptávky dobrovolníkem automaticky SMS s jeho kontaktem.'
      f.input :subscriber_email, input_html: { maxlength: 64 }
      address_label = proc { |type| I18n.t("activerecord.attributes.request.#{type}") }
      custom_input :full_address, class: 'geocomplete',
                                  label: object.new_record? ? (address_label['full_address'] + ' *') : address_label['update_address'],
                                  hint: ("Současná adresa: #{f.object.address}" if resource.address)

      address_object = f.object.address || f.object.build_address
      f.inputs for: [:address, address_object] do |address_form|
        address_form.input :street_number, as: :hidden
        address_form.input :street, as: :hidden
        address_form.input :city, as: :hidden
        address_form.input :city_part, as: :hidden
        address_form.input :postal_code, as: :hidden
        address_form.input :country_code, as: :hidden
        address_form.input :latitude, as: :hidden, input_html: { value: address_object.coordinate.lat }
        address_form.input :longitude, as: :hidden, input_html: { value: address_object.coordinate.lon }
        address_form.input :geo_entry_id, as: :hidden
      end
      f.input :long_text, as: :text, hint: 'Tento popis bude dostupny na webu po zveřejnění'
      f.input :is_public
    end

    f.inputs 'Koordinace' do
      organisations = current_user.cached_admin? ? Organisation.all : Organisation.user_group_organisations(current_user)

      f.input :state if resource.persisted?
      f.input :organisation, as: :select,
                             collection: organisations,
                             include_blank: false
      f.input :block_volunteer_until, as: :date_time_picker, input_html: { autocomplete: 'off' }
      f.input :coordinator_id, as: :select, collection: current_user.organisation_colleagues
      f.input :follow_up_after, as: :date_time_picker, input_html: { autocomplete: 'off' }
      f.input :closed_note, as: :text if resource.persisted?
      f.input :created_by_id, as: :hidden, input_html: { value: current_user.id }
    end
    f.actions
  end
end
