# frozen_string_literal: true

ActiveAdmin.register RequestedVolunteer do
  decorate_with RequestedVolunteerDecorator

  belongs_to :organisation_request, parent_class: Request

  permit_params :request_id, :volunteer_id, :state, :visible_sensitive, :note

  controller do
    def create
      super do |success, failure|
        success.html {
          flash[:notice] = 'Dobrovolník přidán do poptávky'
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
    volunteer_id = params[:volunteer_id] || params[:requested_volunteer][:volunteer_id]
    volunteer = Volunteer.find(volunteer_id)

    f.inputs 'Přidání dobrovolníka do poptávky' do
      f.input :volunteer, as: :string, input_html: { value: volunteer.to_s, disabled: true }
      f.input :request, label: 'Poptávka', as: :select,
                        collection: Request.includes(:coordinator)
                                           .assignable
                                           .with_organisations(current_user.coordinating_organisations.pluck(:id))
                                           .without_volunteer(volunteer)
                                           .decorate
                                           .map { |i| [[i.subscriber, i.coordinator].join(' - '), i.id]}
      f.input :state, label: 'Přidat jako', as: :select, collection: [['Potvrzen', :accepted], ['K oslovení', :to_be_notified]]
      f.input :volunteer_id, as: :hidden, input_html: { value: volunteer_id }
    end
    f.actions
  end
end
