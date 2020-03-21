class Group < ApplicationRecord
  # Associations
  has_many :organisation_groups
  has_many :organisations, through: :organisation_groups
  has_many :group_volunteers
  has_many :volunteers, through: :group_volunteers

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  def add_exclusive_volunteer(volunteer)
    GroupVolunteer.create(group: self,
                          is_exclusive: true,
                          volunteer: volunteer,
                          recruitment_status: GroupVolunteer::DEFAULT_RECRUITMENT_STATUS,
                          source: GroupVolunteer.sources[:channel])
  end
end
