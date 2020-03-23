# frozen_string_literal: true

ActiveAdmin.register Role do
  # menu false

  decorate_with RoleDecorator
end
