# frozen_string_literal: true

module Authorizable
  include ActiveSupport::Concern

  def has_any_role?(role_name)
    roles_name.include? role_name.to_s
  end

  def admin?
    has_any_role? :super_admin
  end

  def coordinator?
    has_any_role? :coordinator
  end
end
