# frozen_string_literal: true

ActiveAdmin.register RequestedVolunteer do
  decorate_with RequestedVolunteerDecorator

  belongs_to :organisation_request, parent_class: Request

  permit_params :request_id, :volunteer_id, :state, :visible_sensitive

  controller do
    def create
      super do |success, failure|
        success.html {
          resource.update state: params[:state] if params[:state]
          redirect_to admin_volunteer_path(resource.volunteer_id)
        }
        failure.html { render :new }
      end
    end

    def update
      super do |success, failure|
        notify_volunteers_updated if success.present? && should_notify_update?
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

    def notify_volunteers_updated
      Admin::Requests::VolunteerNotifier.new(current_user, resource.request, resource).notify_updated
    end

    # send update only in case volunteer is has accepted request and sensitive information is visible
    def should_notify_update?
      resource.accepted? && resource.visible_sensitive?
    end
  end

  form do |f|
    f.inputs 'Přidání dobrovolníka do poptávky' do
      f.input :request, label: 'Poptávka', as: :select, collection: Request.assignable.with_organisations(current_user.coordinating_organisations.pluck(:id))
      f.input :state, label: 'Přidat jako', as: :select, collection: [['Potvrzen', :accepted], ['K oslovení', :to_be_notified]]
      f.input :volunteer_id, as: :hidden, input_html: { value: params[:volunteer_id] }
    end
    f.actions
  end
end
