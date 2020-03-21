class GroupVolunteerDecorator < ApplicationDecorator
  decorates_association :volunteer

  delegate_all
end
