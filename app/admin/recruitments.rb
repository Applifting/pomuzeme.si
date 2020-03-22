# frozen_string_literal: true

ActiveAdmin.register Recruitment do
  decorate_with GroupVolunteerDecorator

  scope :in_progress, default: true
  scope :all
  scope :closed

  filter :coordinator, as: :select, collection: proc { current_user.organisation_colleagues.map(&:decorate).map { |u| [u.full_name, u.id] } }

  index do
    column(:group) if current_user.admin?
    column :volunteer
    column :recruitment_status, &:humanized_recruitment_status
    column :source
    column :is_exclusive
    column :coordinator
    column :comments
    column :created_at
    column :updated_at
  end
end
