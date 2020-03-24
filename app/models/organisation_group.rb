class OrganisationGroup < ApplicationRecord
  # Associations
  belongs_to :group
  belongs_to :organisation

  # Attributes
  delegate :name, to: :organisation, prefix: true

  # Validations
  validates :organisation, uniqueness: { scope: :group }
end
