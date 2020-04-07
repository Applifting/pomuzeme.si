# frozen_string_literal: true

class Ability
  include CanCan::Ability
  include Abilities::SuperAdmin
  include Abilities::Coordinator

  def initialize(user)
    add_coordinator_ability user if user.cached_coordinator?
    add_super_admin_ability user if user.cached_admin?
  end
end
