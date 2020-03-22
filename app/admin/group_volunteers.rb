# frozen_string_literal: true

ActiveAdmin.register GroupVolunteer do
  decorate_with GroupVolunteerDecorator

  permit_params :recruitment_status, :coordinator_id, :comments

  form do |f|
    unless object.new_record?
      volunteer = resource.volunteer.decorate

      para [volunteer.full_name, volunteer.phone].join(', ')
      para volunteer.full_address
      para volunteer.description
    end

    f.input :recruitment_status, as: :select, collection: enum_options_for_select(GroupVolunteer, :recruitment_status)
    f.input :coordinator_id, as: :select, collection: User.all
    f.input :comments, as: :text, hint: 'Poznámky k náboru'
    f.actions
  end
end
