class Label < ApplicationRecord
  validates :name, uniqueness: { scope: :group_id }
end
