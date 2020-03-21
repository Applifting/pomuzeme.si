module Abilities
  module Coordinator
    def add_coordinator_ability(user)
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can %i[index read], Organisation
      can :update, Organisation, id: user.coordinating_organisations.pluck(:id)
      can %i[read], [User, UserDecorator], id: user.coordinators_in_organisations.pluck(:id)
      can %i[read download], [Volunteer, VolunteerDecorator]
      cannot %i[read], Volunteer, confirmed_at: nil
      can %i[read], [Group], id: user.coordinating_groups.pluck(:id)
      can :manage, Label # , group_id: user.coordinating_groups.pluck(:id)
      can :manage, VolunteerLabel
      can :manage, [GroupVolunteer, GroupVolunteerDecorator], id: user.group_volunteers.pluck(:id)
      cannot :destroy, [GroupVolunteer, GroupVolunteerDecorator]
    end
  end
end
