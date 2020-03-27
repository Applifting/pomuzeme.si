class Label < ApplicationRecord
  # Associations
  belongs_to :group
  has_many :volunteer_labels, dependent: :destroy

  # Validations
  validates :name, uniqueness: { scope: :group_id }

  # Scopes
  scope :managable_by, ->(user) { where(group_id: user.coordinating_groups.pluck(:id)) }
  scope :alphabetically, -> { order(:name) }
end
