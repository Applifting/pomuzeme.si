# frozen_string_literal: true

ActiveAdmin.register GroupVolunteer do
  decorate_with GroupVolunteerDecorator

  belongs_to :volunteer

  permit_params :comments, :coordinator_id, :group_id, :recruitment_status

  controller do
    def create
      auth_error = proc { |operation, klass| CanCan::AccessDenied.new(I18n.t('errors.authorisation.resource'), operation, klass) }

      # # Is there a GroupVolunteer record for the volunteer that does not belong to the user's org group?
      # intouchible_volunteer = GroupVolunteer.where(volunteer_id: params[:id]).where.not(group_id: current_user.organisation_group.id)
      # raise auth_error[:read, Volunteer] if intouchible_volunteer.present?

      # Is current user part of the submitted organisation_group?
      raise auth_error[:read, Group] if params[:group_volunteer][:group_id].to_i != current_user.organisation_group.id

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

        para [volunteer.full_name, volunteer.phone].join(', ')
        para volunteer.full_address
        para volunteer.description
      end
    end

    f.inputs 'Nábor' do
      recruitment_status = object.new_record? ? GroupVolunteer::WAITING_FOR_CONTACT : resource.recruitment_status

      f.input :group_id, as: :hidden, input_html: { value: object.new_record? ? current_user.organisation_group.id : resource.group_id }
      f.input :recruitment_status, as: :select,
                                   selected: recruitment_status,
                                   collection: enum_options_for_select(GroupVolunteer, :recruitment_status)
      f.input :coordinator_id, as: :select, collection: [[current_user.decorate.full_name, current_user.id]], select: 1
      f.input :comments, as: :text, hint: 'Poznámky k náboru'
    end
    f.actions
  end
end
