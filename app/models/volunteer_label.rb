class VolunteerLabel < ApplicationRecord
  belongs_to :label
  belongs_to :user, foreign_key: :created_by_id
  belongs_to :volunteer

  validates :volunteer, uniqueness: { scope: :label }
end
