class User < ApplicationRecord
  include Authorizable
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  validates :first_name, presence: true
  validates :last_name, presence: true

  def coordinating_organisations
    Organisation.with_role(:coordinator, self)
  end

  def cached_roles_name
    @cached_roles_name ||= roles_name.map &:to_sym
  end

  def has_any_role?(role_name)
    cached_roles_name.include? role_name
  end
end
