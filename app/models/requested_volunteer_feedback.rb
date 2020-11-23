class RequestedVolunteerFeedback < ApplicationRecord
  extend VolunteerFeedback::Helper

  belongs_to :requested_volunteer
end
