# frozen_string_literal: true

ActiveAdmin.register RequestedVolunteer do
  decorate_with RequestedVolunteerDecorator
  belongs_to :organisation_request, parent_class: Request
  permit_params :request_id, :volunteer_id, :state, :visible_sensitive

  controller do
    def create
      super do |success, failure|
        notify_volunteer_assigned if success.present?
        success.html { redirect_to admin_organisation_request_path(resource.request_id) }
        failure.html { render :new }
      end
    end

    def update
      super do |success, failure|
        notify_volunteer_updated if success.present?
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

    private

    def notify_volunteer_assigned
      return unless resource.volunteer.fcm_active?

      Push::Requests::AssignerService.new(resource.request_id, [resource.volunteer]).perform
    end

    def notify_volunteer_updated
      return unless resource.volunteer.fcm_active?

      Push::Requests::UpdaterService.new(resource.request_id, [resource.volunteer]).perform
    end
  end
end
