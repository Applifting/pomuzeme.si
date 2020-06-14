# frozen_string_literal: true

ActiveAdmin.register Recruitment do
  decorate_with GroupVolunteerDecorator

  scope :recruitment_in_progress, default: true, &:in_progress
  scope :recruitment_closed, &:closed
  scope :recruitment_all, &:all
  scope :recruitment_unassigned, &:unassigned

  filter :volunteer_full_name_cont
  filter :coordinator, as: :select,
                       collection: proc { OptionsWrapper.wrap (current_user.organisation_colleagues.map { |i| [i.to_s, i.id] }), params, :coordinator_eq }
  filter :recruitment_status, as: :select, collection: GroupVolunteer.recruitment_statuses
  filter :contract_expires_lteq, as: :date_picker, label: 'Smlouva do data'


  controller do
    def scoped_collection
      super.includes(volunteer: :addresses)
    end
  end

  index do
    column :volunteer
    column :recruitment_status, &:humanized_recruitment_status
    column :address do |resource|
      resource.volunteer&.addresses&.first
    end
    column :source
    column :is_exclusive
    column :coordinator
    column :comments
    column(:group) if current_user.cached_admin?
    column :created_at
    column :updated_at

    actions if current_user.cached_admin?
  end
end
