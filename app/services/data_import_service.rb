module DataImportService
  def self.call(filename, group)
    Importer.new(filename, group).call
  end

  def self.cleanup(group)
    Volunteer.joins(:group_volunteers).where(group_volunteers: { group_id: group.id }).destroy_all
    Request.joins(organisation: :organisation_groups).where(organisation_groups: { id: group.id }).destroy_all
    Label.where(group_id: group.id).destroy_all
  end
end

# TODOs
# find existing coordinators, labels, requests
