# frozen_string_literal: true

class Ability
  include CanCan::Ability
  include Abilities::SuperAdmin
  include Abilities::Coordinator

  def initialize(user)
    add_super_admin_ability user if user.has_role? 'super_admin'.freeze
    add_coordinator_ability user if user.roles_name.include? 'coordinator'.freeze
  end
end
