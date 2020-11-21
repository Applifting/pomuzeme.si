module Abilities
  module Coordinator
    def add_coordinator_ability(user)
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can %i[index read], [Organisation, OrganisationDecorator], id: user.cache_output(:user_group_organisations) { Organisation.user_group_organisations(user).pluck(:id) }
      can :update, [Organisation, OrganisationDecorator], id: user.cache_output(:coordinating_organisations) { user.coordinating_organisation_ids }
      can %i[read], [User, UserDecorator], id: user.cache_output(:group_coordinators) { user.group_coordinators.pluck(:id) }

      can %i[read download], [Volunteer, VolunteerDecorator], id: Volunteer.available_for(user.organisation_group.id).pluck(:id)
      can :manage, [Volunteer, VolunteerDecorator], id: Volunteer.exclusive_for(user.organisation_group.id).pluck(:id)
      can :create, [Volunteer, VolunteerDecorator]
      can :manage, [RequestedVolunteer, RequestedVolunteerDecorator]
      cannot %i[read], Volunteer, confirmed_at: nil

      can :update, [Address, AddressDecorator], Address.all do |address|
        can? :manage, address.addressable
      end

      can %i[read], [Group, GroupDecorator], id: user.cache_output(:coordinating_groups) { user.coordinating_groups.pluck(:id) }

      can :manage, Label, group_id: user.cache_output(:coordinating_groups) { user.coordinating_groups.pluck(:id) }
      can :manage, VolunteerLabel

      can_manage_requests user
      can_manage_recruitment user

      can_import_and_cleanup_data if ENV['ENV_FLAVOR'] == 'staging' || Rails.env.development?
    end

    def can_manage_recruitment(user)
      can %i[index read update], [Recruitment, GroupVolunteer, GroupVolunteerDecorator], group_id: user.organisation_group.id
      cannot :create, Recruitment

      can :create, [GroupVolunteer]
      can %i[read create update], [GroupVolunteer, GroupVolunteerDecorator], id: user.group_volunteers.pluck(:id)
    end

    def can_manage_requests(user)
      can :create, Request
      can :manage, Message

      # read-only access to requests within organisation group
      can %i[index read], [Request, RequestDecorator], organisation_id: user.cache_output(:user_group_organisations) { Organisation.user_group_organisations(user).pluck(:id) }

      # full access to requests in user's organisations
      can :manage, [Request, RequestDecorator], organisation_id: user.cache_output(:coordinating_organisations) { user.coordinating_organisation_ids }.push(nil)
      can :manage, [RequestedVolunteer, RequestedVolunteerDecorator], request: { organisation_id: user.cache_output(:user_group_organisations) { Organisation.user_group_organisations(user).pluck(:id) } }

      # access to ActiveAdmin::Comment
      can %i[index read], ActiveAdmin::Comment, resource_type: 'Request', resource_id: user.coordinator_organisation_requests.pluck(:id)
      can %i[create], ActiveAdmin::Comment, resource_type: 'Request', resource_id: user.organisation_request_ids
      can %i[update destroy], ActiveAdmin::Comment, author: user
    end

    def can_import_and_cleanup_data
      can :manage, (ActiveAdmin.register_page 'Import Data')
    end
  end
end
