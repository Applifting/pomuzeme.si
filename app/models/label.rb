class Label < ApplicationRecord
  has_many :volunteer_labels

  validates :name, uniqueness: { scope: :group_id }
end
