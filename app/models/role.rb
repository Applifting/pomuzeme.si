# frozen_string_literal: true

class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  scope :coordinator, -> { where(name: :coordinator) }
  scope :for_model, -> (resource_class) { where(roles: { resource_type: resource_class }) }

  def to_s
    "#{name} ~ #{resource}"
  end
end
