module Abilities
  module Coordinator
    def add_coordinator_ability(user)
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can %i[index read], Organisation
      can :update, Organisation, id: Organisation.with_role(:coordinator, user).pluck(:id)
      can %i[index read], User
      can %i[index read], Volunteer
      cannot %i[index read], Volunteer, confirmed_at: nil
    end
  end
end