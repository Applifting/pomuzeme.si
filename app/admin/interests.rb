# frozen_string_literal: true

ActiveAdmin.register Interest do
  menu parent: 'Admin'

  permit_params :name, :code, :description
end