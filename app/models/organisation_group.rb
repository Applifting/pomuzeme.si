class OrganisationGroup < ApplicationRecord
  # Associations
  has_many :organisations

  # Validations
  validates :name, presence: true, uniqueness: { scope: :id }
  validates :slug, presence: true, uniqueness: true
end
