# frozen_string_literal: true

ActiveAdmin.register RequestedVolunteer do
  decorate_with RequestedVolunteerDecorator
  belongs_to :organisation_request, :parent_class => Request
  permit_params :request_id, :volunteer_id, :state, :visible_sensitive

  form do |f|
    if object.new_record?
      f.input :volunteer, collection: Volunteer.available_for(current_user.organisation_group.id)
                                               .verified_by(current_user.organisation_group.id),
                          disabled: Volunteer.assigned_to_request(resource.request_id).pluck(:id)
    end
    f.input :state, as: :select,
                    selected: (object.new_record? ? :notified : resource.state),
                    include_blank: false
    f.actions
  end

  show do
    panel resource do
      attributes_table_for resource do
        row :volunteer
        row :request
        row :state
        row :created_at
        row :updated_at
      end
    end

    active_admin_comments
  end

  controller do
    def create
      super do |success, failure|
        success.html { redirect_to admin_organisation_request_path(resource.request_id) }
        failure.html { render :new }
      end
    end

    def update
      super do |success, failure|
        success.html { redirect_to admin_organisation_request_path(resource.request_id) }
        failure.html { render :new }
      end
    end

    def destroy
      super do |success, failure|
        success.html { redirect_to admin_organisation_request_path(resource.request_id) }
        failure.html { render :new }
      end
    end
  end
end
