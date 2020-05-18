# frozen_string_literal: true

ActiveAdmin.register RequestedVolunteer do
  decorate_with RequestedVolunteerDecorator
  belongs_to :organisation_request, parent_class: Request
  permit_params :request_id, :volunteer_id, :state, :visible_sensitive

  controller do
    def create
      super do |success, failure|
        success.html { redirect_to admin_organisation_request_path(resource.request_id) }
        failure.html { render :new }
      end
    end

    def update
      super do |success, failure|
        success.html do
          notify_volunteers_updated if should_notify_update?
          redirect_to admin_organisation_request_path(resource.request_id)
        end
        failure.html { render :new }
      end
    end

    def destroy
      super do |success, failure|
        success.html { redirect_to admin_organisation_request_path(resource.request_id) }
        failure.html { render :new }
      end
    end

    private

    def notify_volunteers_updated
      Admin::Requests::VolunteerNotifier.new(current_user, resource.request).notify_updated
    end

    # send update only in case volunteer is has accepted request and sensitive information is visible
    def should_notify_update?
      resource.accepted? && resource.visible_sensitive?
    end
  end
end
