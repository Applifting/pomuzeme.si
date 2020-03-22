# frozen_string_literal: true

ActiveAdmin.register Recruitment do
  decorate_with GroupVolunteerDecorator
end
