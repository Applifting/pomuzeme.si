# frozen_string_literal: true

ActiveAdmin.register Skill do
  menu parent: 'Admin'

  permit_params :name, :code
end