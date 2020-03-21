class VolunteerDecorator < ApplicationDecorator
  delegate_all

  def confirmed?
    object.confirmed?
  end

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end
