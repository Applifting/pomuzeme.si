# frozen_string_literal: true

ActiveAdmin.register GroupVolunteer do
  permit_params :name, :slug
end
