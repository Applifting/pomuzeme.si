# frozen_string_literal: true

ActiveAdmin.register OrganisationGroup do
  belongs_to :group
  permit_params :group_id, :organisation_id

  controller do
    def create
      super do |success, failure|
        success.html { redirect_to admin_group_path(resource.group_id) }
        failure.html { render :new }
      end
    end

    def destroy
      super do |success, failure|
        success.html { redirect_to admin_group_path(resource.group_id) }
        failure.html { render :new }
      end
    end
  end
end
