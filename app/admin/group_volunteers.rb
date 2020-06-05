# frozen_string_literal: true

ActiveAdmin.register GroupVolunteer do
  decorate_with GroupVolunteerDecorator

  belongs_to :volunteer

  permit_params :comments, :coordinator_id, :group_id, :recruitment_status, :source

  controller do
    def create
      # Is current user part of the submitted organisation_group?
      raise AuthorisationError.new(:read, Group) if params[:group_volunteer][:group_id].to_i != current_user.organisation_group.id

      super do |success, failure|
        success.html { redirect_to admin_volunteer_path(params[:volunteer_id]) }
        failure.html { render :new }
      end
    end

    def update
      super do |success, failure|
        success.html { redirect_to admin_volunteer_path(params[:volunteer_id]) }
        failure.html { render :new }
      end
    end
  end

  form do |f|
    f.inputs 'Info' do
      para 'Nábor vám pomůže organizovat oslovování volných dobrovolníků.', class: 'small'
      para 'Vyznačte si v jakém stavu komunikace s dobrovolníkem jste, udělejte si poznámky.', class: :small
      para 'Dobrovolníky ve stavu "dobrovolník aktivní" uvidíte jako "Ověření" v kartě Dobrovolníci.', class: :small
    end

    unless object.new_record?
      f.inputs 'O dobrovolníkovi' do
        volunteer = resource.volunteer.decorate

        panel '' do
          attributes_table_for volunteer do
            row :full_name, &:to_s
            row :phone
            row :full_address
            row :description
          end
        end
      end
    end

    f.inputs 'Nábor' do
      recruitment_status = object.new_record? ? GroupVolunteer::WAITING_FOR_CONTACT : resource.recruitment_status

      f.input :group_id, as: :hidden, input_html: { value: object.new_record? ? current_user.organisation_group.id : resource.group_id }
      f.input :recruitment_status, as: :select,
                                   selected: recruitment_status,
                                   collection: enum_options_for_select(GroupVolunteer, :recruitment_statuses)
      f.input(:source, as: :hidden, input_html: { value: GroupVolunteer::SRC_PUBLIC_POOL }) if object.new_record?
      f.input :coordinator_id, as: :select, collection: current_user.organisation_colleagues, select: 1
      f.input :contract_expires, as: :date_select
      f.input :comments, as: :text, hint: 'Poznámky k náboru'
    end
    f.actions
  end
end
