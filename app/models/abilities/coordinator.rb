module Abilities
  module Coordinator
    def add_coordinator_ability(user)
      puts 'addming '
      can %i[index read], Organisation
      can :manage, Organisation, id: Organisation.with_role(:coordinator, user).pluck(:id)
    end
  end
end