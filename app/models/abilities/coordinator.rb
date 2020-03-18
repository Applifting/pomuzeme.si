module Abilities
  module Coordinator
    def add_coordinator_ability(user)
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can %i[index read], Organisation
      can :update, Organisation, id: user.coordinating_organisations
      can %i[index read], User, id: user.coordinators_in_organisations
      can %i[index read download], Volunteer
      cannot %i[index read], Volunteer, confirmed_at: nil
    end
  end
end