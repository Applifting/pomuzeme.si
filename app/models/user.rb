# frozen_string_literal: true

class User < ApplicationRecord
  rolify after_add: :handle_new_role
  include Authorizable
  include Cacheable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :coordinating_organisations,
           -> { where(roles: { name: :coordinator }) },
           through: :roles,
           source: :resource,
           source_type: :Organisation
  has_many :created_requests, class_name: 'Request', foreign_key: :created_by_id
  has_many :closed_requests, class_name: 'Request', foreign_key: :closed_by_id
  has_many :requests, class_name: 'Request', foreign_key: :coordinator_id
  has_many :organisation_requests, through: :coordinating_organisations, source: :requests
  has_many :coordinating_groups, through: :coordinating_organisations, source: :groups

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true

  def organisation_colleagues
    coordinating_organisations.map(&:coordinators).flatten.uniq
  end

  def to_s
    [first_name, last_name].compact.join(' ')
  end
  alias title to_s

  def organisation_group
    @organisation_group ||= coordinating_groups.take
  end

  def group_coordinators
    User.joins(:roles).where(roles: { name: :coordinator,
                                      resource_type: :Organisation,
                                      resource_id: coordinating_organisation_ids })
  end

  def organisation_coordinators
    User.with_role(:coordinator, organisation_group)
  end

  def group_volunteers
    GroupVolunteer.joins(group: :organisation_groups)
                  .where(organisation_groups: { organisation_id: coordinating_organisation_ids })
  end

  def coordinator_organisation_requests
    Request.where(organisation_id: coordinating_organisations.select(:id))
  end

  private

  def handle_new_role(_role)
    touch
  end
end
