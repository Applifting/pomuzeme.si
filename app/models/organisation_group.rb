class OrganisationGroup < ApplicationRecord
  # Associations
  belongs_to :group
  belongs_to :organisation

  # Attributes
  delegate :name, to: :organisation, prefix: true

  # Validations
  validates :organisation, uniqueness: { scope: :group }

  # Callbacks
  after_commit :invalidate_coordinators_cache

  private

  def invalidate_coordinators_cache
    group.organisations.each do |organisation|
      User.with_role(:coordinator, organisation).each &:touch
    end
  end
end
