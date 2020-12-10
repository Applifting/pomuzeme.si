class Group < ApplicationRecord
  # Associations
  has_many :labels, dependent: :destroy
  has_many :organisation_groups, dependent: :destroy
  has_many :organisations, through: :organisation_groups
  has_many :group_volunteers, dependent: :destroy
  has_many :volunteers, through: :group_volunteers

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  def build_group_volunteer(volunteer)
    raise TypeError unless volunteer.is_a? Volunteer

    exclusive_volunteer = volunteer.new_record? && exclusive_volunteer_signup

    GroupVolunteer.new group: self,
                       is_exclusive: exclusive_volunteer,
                       volunteer: volunteer,
                       recruitment_status: GroupVolunteer::DEFAULT_RECRUITMENT_STATUS,
                       source: GroupVolunteer.sources[:channel]
  end
end
