class VolunteerDecorator < ApplicationDecorator
  decorates_association :addresses
  delegate_all

  def confirmed?
    object.confirmed?
  end

  def address
    @address ||= addresses[0]
  end

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end
