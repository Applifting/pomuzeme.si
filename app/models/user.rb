# frozen_string_literal: true

class User < ApplicationRecord
  include Authorizable
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :organisations, through: :roles, as: :resource
  has_many :coordinating_organisations,
           -> { where(roles: { name: :coordinator }) },
           through: :roles,
           source: :resource,
           source_type: :Organisation

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true

  def cached_roles_name
    @cached_roles_name ||= roles_name.map &:to_sym
  end

  def has_any_role?(role_name)
    cached_roles_name.include? role_name
  end

  def coordinators_in_organisations
    User.joins(:roles).where(roles: { name: :coordinator,
                                      resource_type: :Organisation,
                                      resource_id: coordinating_organisation_ids })
  end
end
