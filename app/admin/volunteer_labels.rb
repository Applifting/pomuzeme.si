# frozen_string_literal: true

ActiveAdmin.register VolunteerLabel do
  belongs_to :volunteer
  permit_params :volunteer_id, :label_id, :created_by_id

  controller do
    def create
      super do |success, failure|
        success.html { redirect_to admin_volunteer_path(resource.volunteer_id) }
        failure.html { render :new }
      end
    end

    def destroy
      super do |success, failure|
        success.html { redirect_to admin_volunteer_path(resource.volunteer_id) }
        failure.html { render :new }
      end
    end
  end

  form do |f|
    labels = Label.managable_by current_user
    taken_labels = VolunteerLabel.where(volunteer_id: params[:volunteer_id]).pluck(:label_id)

    f.inputs do
      f.input :label_id, as: :select,
                         collection: labels,
                         disabled: taken_labels
      f.input :volunteer_id, as: :hidden, input_html: { value: params[:volunteer_id] }
      f.input :created_by_id, as: :hidden, input_html: { value: current_user.id }
    end
    f.actions
  end
end
