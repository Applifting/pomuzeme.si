class UserDecorator < ApplicationDecorator

  # decorates_association :roles

  delegate_all

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end