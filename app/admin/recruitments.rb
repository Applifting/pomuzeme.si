# frozen_string_literal: true

ActiveAdmin.register Recruitment do
  decorate_with GroupVolunteerDecorator

  scope :recruitment_in_progress, default: true, &:in_progress
  scope :recruitment_closed, &:closed
  scope :recruitment_all, &:all
  scope :recruitment_unassigned, &:unassigned

  filter :coordinator, as: :select, collection: proc { current_user.organisation_colleagues.map(&:decorate).map { |u| [u.full_name, u.id] } }

  controller do
    def scoped_collection
      super.includes(volunteer: :addresses)
    end
  end

  index do
    column(:group) if current_user.admin?
    column :volunteer
    column :address do |resource|
      resource.volunteer&.addresses&.first
    end
    column :recruitment_status, &:humanized_recruitment_status
    column :source
    column :is_exclusive
    column :coordinator
    column :comments
    column :created_at
    column :updated_at

    actions if current_user.admin?
  end
end
