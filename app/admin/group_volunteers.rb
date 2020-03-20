# frozen_string_literal: true

ActiveAdmin.register GroupVolunteer do
  permit_params :name, :slug

  form do |f|
    f.input :recruitment_status, as: :select, collection: enum_options_for_select(GroupVolunteer, :recruitment_status)
    f.input :coordinator, as: :select, collection: User.all
    f.input :comments, as: :text, hint: 'Poznámky k náboru'
    f.actions
  end
end
