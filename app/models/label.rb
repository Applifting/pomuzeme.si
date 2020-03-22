class Label < ApplicationRecord
  # Associations
  belongs_to :group
  has_many :volunteer_labels

  # Validations
  validates :name, uniqueness: { scope: :group_id }
end
