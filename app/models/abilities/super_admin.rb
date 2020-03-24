module Abilities
  module SuperAdmin
    def add_super_admin_ability(user)
      can :manage, :all
      cannot :destroy, :all
      can :destroy, [Volunteer, VolunteerDecorator]
    end
  end
end