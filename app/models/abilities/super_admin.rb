module Abilities
  module SuperAdmin
    def add_super_admin_ability(user)
      can :manage, :all
    end
  end
end