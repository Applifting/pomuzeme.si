# frozen_string_literal: true

ActiveAdmin.register VolunteerLabel do
  belongs_to :volunteer
  permit_params :volunteer_id, :label_id, :created_by_id

  controller do
    def create
      super do |success, failure|
        success.html { redirect_to admin_volunteer_path(resource.group_id) }
        failure.html { render :new }
      end
    end

    def destroy
      super do |success, failure|
        success.html { redirect_to admin_volunteer_path(resource.group_id) }
        failure.html { render :new }
      end
    end
  end
end
