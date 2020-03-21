class VolunteerLabel < ApplicationRecord
  # Associations
  belongs_to :label
  belongs_to :user, foreign_key: :created_by_id, optional: true
  belongs_to :volunteer

  # Validations
  validates :volunteer_id, uniqueness: { scope: :label_id }

  # Delegations
  delegate :name, to: :label
end
