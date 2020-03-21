class GroupVolunteerDecorator < ApplicationDecorator
  decorates_association :volunteer

  delegate_all

  def title
    object.volunteer.decorate.full_name
  end
end
