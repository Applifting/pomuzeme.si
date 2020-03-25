# frozen_string_literal: true

class UserRole < ApplicationRecord
  self.table_name = :users_roles

  # Associations
  belongs_to :user
  belongs_to :role
end
