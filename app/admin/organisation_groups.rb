# frozen_string_literal: true

ActiveAdmin.register OrganisationGroup do
  permit_params :name, :slug
end
