module DataImportService
  def self.call(filename, group)
    Importer.new(filename, group).call
  end

  def self.cleanup(group)
    group_organisations = Organisation.joins(:organisation_groups).where(organisation_groups: { group_id: group.id })

    Request.where(organisation_id: group_organisations.pluck(:id)).destroy_all if group_organisations.present?

    Volunteer.joins(:group_volunteers)
             .where(group_volunteers: { group_id: group.id, is_exclusive: true })
             .destroy_all

    Label.where(group_id: group.id)
         .destroy_all
  end
end
