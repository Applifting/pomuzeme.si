class VolunteerLabel < ApplicationRecord
  # Associations
  belongs_to :label
  belongs_to :volunteer
  belongs_to :user, foreign_key: :created_by_id, optional: true

  # Validations
  validates :volunteer_id, uniqueness: { scope: :label_id }

  # Delegations
  delegate :name, to: :label

  # Scopes
  scope :managable_by, ->(user) { joins(:label).where(labels: { group_id: user.coordinating_groups.pluck(:id) }) }
end
