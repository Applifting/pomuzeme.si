class Group < ApplicationRecord
  # Associations
  has_many :organisation_groups
  has_many :organisations, through: :organisation_groups

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
end
